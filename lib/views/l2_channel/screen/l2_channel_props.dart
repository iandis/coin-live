part of '_l2_channel_screen.dart';

abstract class _L2ChannelScreenProps extends State<L2ChannelScreen> {
  final _navigationService = GetIt.I<BaseNavigationService>();
  final _l2channelBloc = L2ChannelBloc();
  final _scrollController = ScrollController();

  late double screenWidth;
  late Widget emptySpaceForBidAskList;

  @override
  void initState() {
    super.initState();
    _l2channelBloc.add(
      SubscribeL2ChannelEvent(widget.symbol),
    );
  }

  @override
  void dispose() {
    _l2channelBloc.add(const UnsubscribeL2ChannelEvent());
    _l2channelBloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  bool onBackPressed() {
    if (!_scrollController.hasClients) return true;
    if (_scrollController.offset > 0.0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastLinearToSlowEaseIn,
      );
      return false;
    }
    return true;
  }
}
