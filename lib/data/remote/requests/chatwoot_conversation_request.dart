import 'package:equatable/equatable.dart';

class ChatwootConversationRequest extends Equatable {
  final String? sourceId;
  final String? additionalAttributes;
  final String? customAttributes;
  final String? snoozedUntil;
  final String? status;
  final String? priority;
  final String? assigneeId;
  final List<String>? labelList;

  ChatwootConversationRequest({
    this.sourceId,
    this.additionalAttributes,
    this.customAttributes,
    this.snoozedUntil,
    this.status,
    this.priority,
    this.assigneeId,
    this.labelList,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (sourceId != null) data['source_id'] = sourceId;
    if (additionalAttributes != null) data['additional_attributes'] = additionalAttributes;
    if (customAttributes != null) data['custom_attributes'] = customAttributes;
    if (snoozedUntil != null) data['snoozed_until'] = snoozedUntil;
    if (status != null) data['status'] = status;
    if (priority != null) data['priority'] = priority;
    if (assigneeId != null) data['assignee_id'] = assigneeId;
    if (labelList != null) data['label_list'] = labelList;
    return data;
  }

  @override
  List<Object?> get props => [
    sourceId,
    additionalAttributes,
    customAttributes,
    snoozedUntil,
    status,
    priority,
    assigneeId,
    labelList,
  ];
} 