toImmutable = require 'app/util/toImmutable'
immutable   = require 'immutable'
isEmailValid = require 'app/util/isEmailValid'
getFullnameFromAccount = require 'app/util/getFullnameFromAccount'


team = ['TeamStore']
TeamMembersIdStore = ['TeamMembersIdStore']
UsersStore = ['UsersStore']
TeamMembersRoleStore = ['TeamMembersRoleStore']
searchInputValue = ['TeamSearchInputValueStore']
invitationInputValues = ['TeamInvitationInputValuesStore']
loggedInUserEmail = ['LoggedInUserEmailStore']
teamInvitations = ['TeamInvitationStore']
disabledUsers = ['TeamDisabledMembersStore']

pendingInvitations = [
  teamInvitations
  (invitations) ->
    invitations.filter (invitation) ->
      invitation.get('status') is 'pending'
]

membersWithRole = [
  TeamMembersIdStore
  TeamMembersRoleStore
  UsersStore
  (ids, roles, members) ->
    return ids.map (id) ->
      role = roles.get id
      members.get(id).set('role', role)  if role
]

isValidMemberValue = (member, value) ->
  re = new RegExp(value, 'i')

  if member.get('status') is 'pending'
    re.test(member.get('firstName')) or \
    re.test(member.get('lastName')) or \
    re.test(member.get('email'))
  else
    re.test(member.get('profile').get('firstName')) or \
    re.test(member.get('profile').get('lastName')) or \
    re.test(member.get('profile').get('email'))


membersWithPendingInvitations = [
  membersWithRole
  pendingInvitations
  (members, pendingMembers) ->

    pendingMembers.toArray().forEach (invitation) ->
      members = members.set invitation.get('_id'), invitation

    return members
]

sortedMembersWithPendingInvitations = [
  membersWithPendingInvitations
  (members) ->

    members.sortBy (member) ->
      if member
        if member.get('status') is 'pending'
          member.get('firstName')  if member.get 'firstname'
          member.get('lastName')  if member.get 'lastName'
          member.get('email')
        else
          member.getIn(['profile', 'firstName'])  if member.getIn(['profile', 'firstName'])
          member.getIn(['profile', 'lastName'])  if member.getIn(['profile', 'lastName'])
          member.getIn(['profile', 'email'])
]


filteredMembersWithRole = [
  sortedMembersWithPendingInvitations
  searchInputValue
  (members, value) ->
    return members  if value is ''
    members.filter (member) -> isValidMemberValue member, value
]

filteredMembersWithRoleAndDisabledUsers = [
  filteredMembersWithRole
  disabledUsers
  (users, disabledUsers) ->
    users.withMutations (users) ->
      disabledUsers.map (disabledUser) ->
        users.set disabledUser.get('_id'), disabledUser
]


allInvitations = [
  invitationInputValues
  loggedInUserEmail
  (inputValues, ownEmail) ->
    inputValues.filter (value) ->
      email = value.get('email').trim()
      return (email isnt ownEmail) and isEmailValid(email)
]


adminInvitations = [
  allInvitations
  (allInvitations) ->
    allInvitations.filter (value) -> value.get 'canEdit'
]

newInvitations = [
  allInvitations
  pendingInvitations
  (allInvitations, pendingInvitations) ->
    pendingEmails = pendingInvitations
      .map (i) -> i.get 'email'
      .toArray()

    allInvitations = allInvitations.filter (invitation) ->
      invitation.get('email')  not in pendingEmails
]

resendInvitations = [
  allInvitations
  pendingInvitations
  (allInvitations, pendingInvitations) ->

    invitationEmails = allInvitations
      .map (i) -> i.get 'email'
      .toArray()

    pendingInvitations = pendingInvitations.filter (pendingInvitation) ->
      pendingInvitation.get('email') in invitationEmails
]


module.exports = {
  team
  loggedInUserEmail
  membersWithRole
  TeamMembersIdStore
  invitationInputValues
  searchInputValue
  filteredMembersWithRole
  adminInvitations
  allInvitations
  newInvitations
  pendingInvitations
  resendInvitations
  disabledUsers
  filteredMembersWithRoleAndDisabledUsers
}
