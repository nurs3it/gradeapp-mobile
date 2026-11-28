import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/learner/study_proof.dart';

void main() {
  test('request rows: status, the issued proof and when a new request is allowed', () {
    final issued = ProofRequest.fromJson({
      'id': 'r1',
      'status': 'issued',
      'purpose': 'В поликлинику',
      'created_at': '2026-11-20T08:00:00Z',
      'study_proof': {
        'display_number': '17/2026',
        'issued_at': '2026-11-21T09:00:00Z',
        'verify_url': 'https://grade-app.kz/v/ABC',
        'pdf_url': 'https://grade-app.kz/api/certificates/study-proof-requests/r1/pdf/',
      },
    });
    expect(issued.status, ProofRequestStatus.issued);
    expect(issued.proof?.number, '17/2026');
    expect(issued.proof?.verifyUrl, 'https://grade-app.kz/v/ABC');
    final pending = ProofRequest.fromJson({'id': 'r2', 'status': 'pending', 'study_proof': null});
    expect(pending.proof, isNull);
    expect(canRequestProof([issued]), isTrue);
    expect(canRequestProof([issued, pending]), isFalse);
    expect(ProofRequest.fromJson({'id': 'r3', 'status': 'declined'}).status, ProofRequestStatus.declined);
  });
}
