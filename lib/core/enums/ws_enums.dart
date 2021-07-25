enum WSAction {
  subscribe,
  unsubscribe,
}

extension WSActionName on WSAction {
  String get name {
    switch (index) {
      case 0:
        return 'subscribe';
      case 1:
        return 'unsubscribe';
    }
    throw IndexError(index, WSAction);
  }
}

enum WSChannel {
  heartbeat,
  l2,
  l3,
  prices,
  symbols,
  ticker,
  trades,
  auth,
  balances,
  trading,
}

extension WSChannelName on WSChannel {
  String get name {
    switch (index) {
      case 0:
        return 'heartbeat';
      case 1:
        return 'l2';
      case 2:
        return 'l3';
      case 3:
        return 'prices';
      case 4:
        return 'symbols';
      case 5:
        return 'ticker';
      case 6:
        return 'trades';
      case 7:
        return 'auth';
      case 8:
        return 'balances';
      case 9:
        return 'trading';
    }
    throw IndexError(index, WSChannel);
  }
}

enum WSEvent {
  subscribed,
  unsubscribed,
  rejected,
  snapshot,
  updated,
}

extension WSEventName on WSEvent {
  String get name {
    switch (index) {
      case 0:
        return 'subscribed';
      case 1:
        return 'unsubscribed';
      case 2:
        return 'rejected';
      case 3:
        return 'snapshot';
      case 4:
        return 'updated';
    }
    throw IndexError(index, WSEvent);
  }
}

enum WSSymbolStatus {
  open,
  close,
  suspend,
  halt,
  haltFreeze,
}

extension WSSymbolStatusName on WSSymbolStatus {
  String get name {
    switch(index) {
      case 0:
        return 'open';
      case 1:
        return 'close';
      case 2:
        return 'suspend';
      case 3:
        return 'halt';
      case 4:
        return 'halt-freeze';
    }
    throw IndexError(index, WSSymbolStatus);
  }
}