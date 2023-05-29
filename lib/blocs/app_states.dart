import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class PostState extends Equatable {}

// data loading state
class PostLoadindState extends PostState {
  @override
  List<Object?> get props => [];
}

// data loaded state 


// data error loading state