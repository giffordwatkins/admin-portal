// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:redux/redux.dart';

// Project imports:
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/main_app.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/recurring_invoice/recurring_invoice_actions.dart';
import 'package:invoiceninja_flutter/redux/recurring_invoice/recurring_invoice_selectors.dart';
import 'package:invoiceninja_flutter/redux/ui/ui_actions.dart';
import 'package:invoiceninja_flutter/ui/app/dialogs/error_dialog.dart';
import 'package:invoiceninja_flutter/ui/invoice/edit/invoice_edit_vm.dart';
import 'package:invoiceninja_flutter/ui/recurring_invoice/edit/recurring_invoice_edit.dart';
import 'package:invoiceninja_flutter/ui/recurring_invoice/view/recurring_invoice_view_vm.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';

class RecurringInvoiceEditScreen extends StatelessWidget {
  const RecurringInvoiceEditScreen({Key key}) : super(key: key);

  static const String route = '/recurring_invoice/edit';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RecurringInvoiceEditVM>(
      converter: (Store<AppState> store) {
        return RecurringInvoiceEditVM.fromStore(store);
      },
      builder: (context, viewModel) {
        return RecurringInvoiceEdit(
          viewModel: viewModel,
          key: ValueKey(viewModel.invoice.updatedAt),
        );
      },
    );
  }
}

class RecurringInvoiceEditVM extends AbstractInvoiceEditVM {
  RecurringInvoiceEditVM({
    AppState state,
    CompanyEntity company,
    InvoiceEntity invoice,
    int invoiceItemIndex,
    InvoiceEntity origInvoice,
    Function(BuildContext) onSavePressed,
    Function(List<InvoiceItemEntity>, String, String) onItemsAdded,
    bool isSaving,
    Function(BuildContext) onCancelPressed,
  }) : super(
          state: state,
          company: company,
          invoice: invoice,
          invoiceItemIndex: invoiceItemIndex,
          origInvoice: origInvoice,
          onSavePressed: onSavePressed,
          onItemsAdded: onItemsAdded,
          isSaving: isSaving,
          onCancelPressed: onCancelPressed,
        );

  factory RecurringInvoiceEditVM.fromStore(Store<AppState> store) {
    final AppState state = store.state;
    final recurringInvoice = state.recurringInvoiceUIState.editing;

    return RecurringInvoiceEditVM(
      state: state,
      company: state.company,
      isSaving: state.isSaving,
      invoice: recurringInvoice,
      invoiceItemIndex: state.recurringInvoiceUIState.editingItemIndex,
      origInvoice: store.state.recurringInvoiceState.map[recurringInvoice.id],
      onSavePressed: (BuildContext context, [EntityAction action]) {
        Debouncer.runOnComplete(() {
          final recurringInvoice = store.state.recurringInvoiceUIState.editing;
          final localization = navigatorKey.localization;
          final navigator = navigatorKey.currentState;

          if (recurringInvoice.clientId.isEmpty) {
            showDialog<ErrorDialog>(
                context: navigatorKey.currentContext,
                builder: (BuildContext context) {
                  return ErrorDialog(localization.pleaseSelectAClient);
                });
            return null;
          }
          if (recurringInvoice.isOld &&
              !hasRecurringInvoiceChanges(
                  recurringInvoice, state.recurringInvoiceState.map) &&
              action != null) {
            handleEntityAction(recurringInvoice, action);
          } else {
            final Completer<InvoiceEntity> completer =
                Completer<InvoiceEntity>();
            store.dispatch(SaveRecurringInvoiceRequest(
                completer: completer,
                recurringInvoice: recurringInvoice,
                action: action));
            return completer.future.then((savedRecurringInvoice) {
              showToast(recurringInvoice.isNew
                  ? localization.createdRecurringInvoice
                  : localization.updatedRecurringInvoice);

              if (state.prefState.isMobile) {
                store.dispatch(
                    UpdateCurrentRoute(RecurringInvoiceViewScreen.route));
                if (recurringInvoice.isNew) {
                  navigator
                      .pushReplacementNamed(RecurringInvoiceViewScreen.route);
                } else {
                  navigator.pop(savedRecurringInvoice);
                }
              } else {
                viewEntity(entity: savedRecurringInvoice);

                if (state.prefState.isEditorFullScreen(EntityType.invoice)) {
                  editEntity(
                      context: navigatorKey.currentContext,
                      entity: savedRecurringInvoice);
                }
              }
            }).catchError((Object error) {
              showDialog<ErrorDialog>(
                  context: navigatorKey.currentContext,
                  builder: (BuildContext context) {
                    return ErrorDialog(error);
                  });
            });
          }
        });
      },
      onItemsAdded: (items, clientId, projectId) {
        if (items.length == 1) {
          store.dispatch(
              EditRecurringInvoiceItem(recurringInvoice.lineItems.length));
        }
        store.dispatch(AddRecurringInvoiceItems(items));
      },
      onCancelPressed: (BuildContext context) {
        if (['pdf', 'email'].contains(state.uiState.previousSubRoute)) {
          viewEntitiesByType(entityType: EntityType.recurringInvoice);
        } else {
          createEntity(context: context, entity: InvoiceEntity(), force: true);
          store.dispatch(UpdateCurrentRoute(state.uiState.previousRoute));
        }
      },
    );
  }
}
