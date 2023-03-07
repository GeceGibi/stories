part of 'pager.dart';

class StoryPagerController {
  var index = -1;

  final _listenersPager = <_StoryPagerState>[];
  void _attachPager(_StoryPagerState state) => _listenersPager.add(state);
  void _detachPager(_StoryPagerState state) => _listenersPager.remove(state);

  final _listenersItem = <_StoryPagerItemState>[];
  void _attachItem(_StoryPagerItemState state) => _listenersItem.add(state);
  void _detachItem(_StoryPagerItemState state) => _listenersItem.remove(state);

  void pause() {
    if (index == -1) {
      for (final listener in _listenersItem) {
        listener.pause();
      }
    } else {
      _listenersItem[index].pause();
    }
  }

  void resume() {
    if (index == -1) {
      for (final listener in _listenersItem) {
        listener.play();
      }
    } else {
      _listenersItem[index].paused = false;
      _listenersItem[index].play();
    }
  }

  void goNextPage() {
    for (final listener in _listenersPager) {
      listener.goNextPage();
    }
  }

  void goPrevPage() {
    for (final listener in _listenersPager) {
      listener.goPrevPage();
    }
  }

  void goPage(int index) {
    for (final listener in _listenersPager) {
      listener.goPage(index);
    }
  }
}
