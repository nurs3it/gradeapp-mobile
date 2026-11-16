import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/learner/report_card.dart';

void main() {
  test('reads the UTF-8 file name the backend sends', () {
    const header = "attachment; filename*=UTF-8''%D0%A2%D0%B0%D0%B1%D0%B5%D0%BB%D1%8C_%D0%90%D0%BB%D0%B8%D1%8F_1.pdf";
    expect(fileNameFromDisposition(header), 'Табель_Алия_1.pdf');
    expect(fileNameFromDisposition('attachment; filename="card.pdf"'), 'card.pdf');
    expect(fileNameFromDisposition(null), isNull);
  });

  test('a file name never escapes the temp folder', () {
    expect(safeFileName('../../etc/passwd', fallback: 'x.pdf'), '.._.._etc_passwd');
    expect(safeFileName('  ', fallback: 'report-card-1.pdf'), 'report-card-1.pdf');
  });

  test('the Word fallback keeps its own type', () {
    expect(mimeOfReportCard('application/pdf'), 'application/pdf');
    expect(
      mimeOfReportCard('application/vnd.openxmlformats-officedocument.wordprocessingml.document; charset=x'),
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
    expect(mimeOfReportCard(null), 'application/pdf');
  });

  test('errors map to an honest message', () {
    final req = RequestOptions(path: '/x');
    expect(
      reportCardErrorOf(DioException(requestOptions: req, type: DioExceptionType.connectionError)),
      ReportCardError.offline,
    );
    expect(
      reportCardErrorOf(
        DioException(
          requestOptions: req,
          response: Response<void>(requestOptions: req, statusCode: 403),
        ),
      ),
      ReportCardError.denied,
    );
    expect(
      reportCardErrorOf(
        DioException(
          requestOptions: req,
          response: Response<void>(requestOptions: req, statusCode: 500),
        ),
      ),
      ReportCardError.failed,
    );
  });
}
