import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension PreviewComposerAttachmentExtension on ComposerController  {
  void previewAttachment(BuildContext context, UploadTaskId uploadId) {
    final attachment = uploadController.getAttachmentByUploadId(uploadId);

    if (attachment == null) {
      appToast.showToastWarningMessage(
        context,
        AppLocalizations.of(context).noPreviewAvailable,
      );
      return;
    }

    previewAttachmentAction(
      context: context,
      attachment: attachment,
      accountId: mailboxDashBoardController.accountId.value,
      session: mailboxDashBoardController.sessionCurrent,
      controller: this,
      parseEmailInteractor: parseEmailByBlobIdInteractor,
      getHtmlInteractor: getHtmlContentFromAttachmentInteractor,
      onDownloadAttachment: (_) {},
    );
  }
}
