class GroupInvitation {
  String groupId;
  String groupName;
  int status;

  GroupInvitation({this.groupId, this.groupName, this.status});

  @override
  String toString() {
    return 'GroupInvitation -- Group ID $groupId -- Group Name $groupName -- Status $status';
  }
}
