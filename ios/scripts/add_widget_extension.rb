#!/usr/bin/env ruby
# Adds the GradeAppWidgets WidgetKit extension (W1, W2, W5 Live Activity) to
# Runner.xcodeproj, plus the Swift files that join the Runner target. Safe to
# run again: it does nothing when the target exists.
#
#   cd ios && ruby scripts/add_widget_extension.rb
#
# The `xcodeproj` gem ships with CocoaPods. Signing team 6Y5RQZ368G.
require 'xcodeproj'

TEAM = '6Y5RQZ368G'
NAME = 'GradeAppWidgets'
BUNDLE = 'kz.gradeapp.gradeapp.GradeAppWidgets'

proj = Xcodeproj::Project.open('Runner.xcodeproj')
if proj.targets.any? { |t| t.name == NAME }
  puts "#{NAME} already in the project"
  exit
end

runner = proj.targets.find { |t| t.name == 'Runner' }
ext = proj.new_target(:app_extension, NAME, :ios, '16.2', nil, :swift)

# --- files -------------------------------------------------------------
group = proj.main_group.new_group(NAME, NAME)
sources = Dir["#{NAME}/*.swift"].sort.map { |f| group.new_file(File.basename(f)) }
ext.add_file_references(sources)
group.new_file('Info.plist')
group.new_file("#{NAME}.entitlements")

shared = proj.main_group.new_group('Shared', 'Shared')
attrs = shared.new_file('LessonActivityAttributes.swift')
ext.add_file_references([attrs])
runner.add_file_references([attrs])

runner_group = proj.main_group.children.find { |g| g.display_name == 'Runner' }
live = runner_group.new_file('LiveActivity.swift')
runner.add_file_references([live])

# Onest, bundled in the extension (UIAppFonts in its Info.plist).
fonts = %w[Regular SemiBold Bold ExtraBold].map do |w|
  proj.main_group.new_file("../assets/fonts/Onest-#{w}.ttf")
end
fonts.each { |f| ext.resources_build_phase.add_file_reference(f) }

# --- build settings ----------------------------------------------------
flutter_group = proj.main_group.children.find { |g| g.display_name == 'Flutter' }
version_conf = flutter_group.new_file('Flutter/GradeAppWidgets.xcconfig')

proj.build_configurations.map(&:name).each do |cfg|
  conf = ext.build_configurations.find { |c| c.name == cfg } || ext.add_build_configuration(cfg, cfg == 'Debug' ? :debug : :release)
  # FLUTTER_BUILD_NAME / NUMBER for Info.plist (ios/Flutter/GradeAppWidgets.xcconfig).
  conf.base_configuration_reference = version_conf
  conf.build_settings.merge!(
    'PRODUCT_BUNDLE_IDENTIFIER' => BUNDLE,
    'PRODUCT_NAME' => '$(TARGET_NAME)',
    'INFOPLIST_FILE' => "#{NAME}/Info.plist",
    'CODE_SIGN_ENTITLEMENTS' => "#{NAME}/#{NAME}.entitlements",
    'CODE_SIGN_STYLE' => 'Automatic',
    'DEVELOPMENT_TEAM' => TEAM,
    'SWIFT_VERSION' => '5.0',
    'IPHONEOS_DEPLOYMENT_TARGET' => '16.2',
    'TARGETED_DEVICE_FAMILY' => '1,2',
    'SKIP_INSTALL' => 'YES',
    'CURRENT_PROJECT_VERSION' => '$(FLUTTER_BUILD_NUMBER)',
    'LD_RUNPATH_SEARCH_PATHS' => ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks'],
    'SWIFT_EMIT_LOC_STRINGS' => 'NO'
  )
end

# --- embed into Runner -------------------------------------------------
runner.add_dependency(ext)
embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
build_file = embed.add_file_reference(ext.product_reference, true)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
# Must precede "Thin Binary", or Xcode reports a dependency cycle.
runner.build_phases.delete(embed)
at = runner.build_phases.index { |p| p.respond_to?(:name) && p.name == 'Thin Binary' } || runner.build_phases.length
runner.build_phases.insert(at, embed)

proj.save
puts "added #{NAME}"
