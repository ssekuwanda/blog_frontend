import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class PostState extends Equatable {}

class PostLoadindState extends PostState {
  @override
  List<Object?> get props => [];
}
