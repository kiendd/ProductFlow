# Writing style for product documents

These documents are read by people skimming for one fact and by agents parsing for structure.
Both need the same thing: facts on anchors, no filler.

## Rules

**One fact per sentence.** If a sentence contains "and" joining two claims, split it.

**Answer first.** A section opens with its conclusion. Context comes after, if at all.

**Load-bearing facts sit on a scan anchor.** An anchor is a table row, a bullet starting with
`**Term**: fact`, or a code fence. A fact buried mid-paragraph will be missed by a skimming
reader and cannot be extracted by a script.

**No hype, no hedging.** Cut "powerful", "seamless", "simply", "just", "robust", "of course".
Cut "we believe", "it should probably". A requirement either holds or it does not.

**Observable behavior, not implementation.** Write what a user or a caller can see. Names of
classes, functions, and libraries belong in the change's `## Design` section, not in a PRD.

**Present tense, active voice.** "The system returns a PDF", not "a PDF will be returned".

**Statements use the modal.** `PHẢI` / `MUST` for obligations, `NÊN` / `SHOULD` for
recommendations, `CÓ THỂ` / `MAY` for options. Exactly one modal per statement.

**Scenarios are concrete.** Name the trigger and the observable result. A scenario you cannot
turn into a test is not a scenario.

**Unknowns go to `## Open Questions`.** Never fill a gap with a plausible guess; a guessed
requirement is worse than a missing one because it looks verified.

## Bad → good

**1. Buried fact, hype, two claims in one sentence.**

Bad:
> Our powerful invoicing engine seamlessly handles a wide variety of document generation needs
> and users can generally export things in the formats they need.

Good:
> Người dùng tải hoá đơn ở định dạng PDF.
>
> - **Định dạng hỗ trợ**: PDF, không có định dạng khác
> - **Điều kiện**: hoá đơn đã phát hành

**2. Implementation leaking into a requirement.**

Bad:
> **Statement**: `InvoiceService.renderPdf()` gọi thư viện `pdfkit` để dựng file rồi lưu vào S3.

Good:
> **Statement**: Hệ thống PHẢI trả về file PDF của một hoá đơn đã phát hành trong vòng 3 giây.

(The library and the class name go in the change's `## Design` section; the path goes in
`## Implementation Map`.)

**3. Vague scenario that cannot become a test.**

Bad:
> #### Scenario: Xử lý lỗi
> - **WHEN** có lỗi xảy ra
> - **THEN** hệ thống xử lý phù hợp

Good:
> #### Scenario: Hoá đơn chưa phát hành
> - **WHEN** người dùng gọi tải PDF cho một hoá đơn ở trạng thái nháp
> - **THEN** hệ thống trả về lỗi 409 và không sinh file
