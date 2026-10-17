
class HomeState {}

class Initialize extends HomeState{}

class Loading extends HomeState{}

class Success extends HomeState{
    final List<String> entries;
    Success(this.entries);
}

class Failure extends HomeState{
    final String error;

    Failure(this.error);
}

class Empty extends HomeState{}