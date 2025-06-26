import 'package:example/bloc_example/users_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocUserListScreen extends StatelessWidget {
  const BlocUserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (_, state) {
          if (state is UserLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(state.users[i].name),
                subtitle: Text(state.users[i].email),
              ),
            );
          } else if (state is UserError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return SizedBox();
        },
      ),
    );
  }
}
