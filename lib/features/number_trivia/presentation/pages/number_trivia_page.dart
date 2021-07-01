import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tddcource/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:tddcource/features/number_trivia/presentation/widgets/loading_widget.dart';
import 'package:tddcource/features/number_trivia/presentation/widgets/message_display.dart';
import 'package:tddcource/features/number_trivia/presentation/widgets/trivia_controls.dart';
import 'package:tddcource/features/number_trivia/presentation/widgets/trivia_display.dart';
import 'package:tddcource/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: buildBody(context),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: <Widget>[
              //Top half
              Expanded(
                child: BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                  builder: (context, state) {
                    if (state is Empty) {
                      return MessageDisplay(
                        message: 'Start searching!',
                      );
                    } else if (state is Loading) {
                      return LoadingWidget();
                    } else if (state is Loaded) {
                      return TriviaDisplay(trivia: state.trivia);
                    } else if (state is Error) {
                      return MessageDisplay(message: state.message);
                    }
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: Placeholder(),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              //Bottom half
              TriviaControls(),
            ],
          ),
        ),
      ),
    );
  }
}