import 'package:get/get.dart';

import 'package:shamstore/features/wallet/models/wallet_transaction_model.dart';
import 'package:shamstore/features/wallet/repositories/wallet_repository.dart';

class WalletController extends GetxController {
  WalletController({WalletRepository? repository})
    : _repository = repository ?? WalletRepository();

  final WalletRepository _repository;

  final RxList<WalletTransactionModel> pendingTransactions =
      <WalletTransactionModel>[].obs;
  final RxList<WalletTransactionModel> completedTransactions =
      <WalletTransactionModel>[].obs;

  final RxBool isLoadingPending = false.obs;
  final RxBool isLoadingCompleted = false.obs;
  final RxBool isLoadingBalance = false.obs;
  final RxBool isWithdrawing = false.obs;
  final RxBool isLoadingMoreTransactions = false.obs;

  final RxInt pendingCurrentPage = 1.obs;
  final RxInt pendingLastPage = 1.obs;
  final RxInt completedCurrentPage = 1.obs;
  final RxInt completedLastPage = 1.obs;

  final RxString pendingError = ''.obs;
  final RxString completedError = ''.obs;
  final RxString balanceError = ''.obs;
  final RxString withdrawalError = ''.obs;
  final RxString withdrawalMessage = ''.obs;
  final Rx<double?> balance = Rx<double?>(null);

  bool get isLoadingTransactions {
    return isLoadingPending.value || isLoadingCompleted.value;
  }

  bool get hasMorePendingTransactions {
    return pendingCurrentPage.value < pendingLastPage.value;
  }

  bool get hasMoreCompletedTransactions {
    return completedCurrentPage.value < completedLastPage.value;
  }

  bool get hasMoreTransactions {
    return hasMorePendingTransactions || hasMoreCompletedTransactions;
  }

  List<WalletTransactionModel> get transactions {
    final result = <WalletTransactionModel>[
      ...pendingTransactions,
      ...completedTransactions,
    ];

    result.sort((first, second) {
      final firstDate = first.createdAt;
      final secondDate = second.createdAt;

      if (firstDate != null && secondDate != null) {
        final dateComparison = secondDate.compareTo(firstDate);
        if (dateComparison != 0) return dateComparison;
      } else if (firstDate != null) {
        return -1;
      } else if (secondDate != null) {
        return 1;
      }

      return second.id.compareTo(first.id);
    });

    return result;
  }

  Future<void> loadTransactions() async {
    await Future.wait([
      fetchTransactions(status: 'pending'),
      fetchTransactions(status: 'completed'),
    ]);
  }

  Future<void> refreshWallet() async {
    await Future.wait([loadBalance(), loadTransactions()]);
  }

  Future<bool> loadBalance() async {
    if (isLoadingBalance.value) return false;

    isLoadingBalance.value = true;
    balanceError.value = '';

    try {
      balance.value = await _repository.getBalance();
      return true;
    } catch (error) {
      balanceError.value = _cleanError(error);
      return false;
    } finally {
      isLoadingBalance.value = false;
    }
  }

  Future<bool> fetchTransactions({
    required String status,
    int page = 1,
    bool append = false,
  }) async {
    final normalizedStatus = status.trim().toLowerCase();
    final isPending = normalizedStatus == 'pending';

    if (!isPending && normalizedStatus != 'completed') {
      return false;
    }

    final loading = isPending ? isLoadingPending : isLoadingCompleted;
    final errorMessage = isPending ? pendingError : completedError;
    final target = isPending ? pendingTransactions : completedTransactions;
    final currentPage = isPending ? pendingCurrentPage : completedCurrentPage;
    final lastPage = isPending ? pendingLastPage : completedLastPage;

    if (loading.value) return false;

    loading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.getTransactionsByStatus(
        status: normalizedStatus,
        page: page,
      );
      if (append) {
        final merged = <int, WalletTransactionModel>{
          for (final transaction in target) transaction.id: transaction,
          for (final transaction in result.transactions)
            transaction.id: transaction,
        };
        target.assignAll(merged.values);
      } else {
        target.assignAll(result.transactions);
      }
      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
      return true;
    } catch (error) {
      errorMessage.value = _cleanError(error);
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMoreTransactions() async {
    if (isLoadingMoreTransactions.value || !hasMoreTransactions) return;

    isLoadingMoreTransactions.value = true;
    try {
      final requests = <Future<bool>>[];
      if (hasMorePendingTransactions) {
        requests.add(
          fetchTransactions(
            status: 'pending',
            page: pendingCurrentPage.value + 1,
            append: true,
          ),
        );
      }
      if (hasMoreCompletedTransactions) {
        requests.add(
          fetchTransactions(
            status: 'completed',
            page: completedCurrentPage.value + 1,
            append: true,
          ),
        );
      }
      await Future.wait(requests);
    } finally {
      isLoadingMoreTransactions.value = false;
    }
  }

  Future<bool> withdraw({
    required String amount,
    required String shamCashNumber,
  }) async {
    if (isWithdrawing.value) return false;

    isWithdrawing.value = true;
    withdrawalError.value = '';
    withdrawalMessage.value = '';

    try {
      withdrawalMessage.value = await _repository.withdraw(
        amount: amount,
        shamCashNumber: shamCashNumber,
      );
      await Future.wait([loadBalance(), fetchTransactions(status: 'pending')]);
      return true;
    } catch (error) {
      withdrawalError.value = _cleanError(error);
      return false;
    } finally {
      isWithdrawing.value = false;
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
