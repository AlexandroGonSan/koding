kd              = require 'kd'
React           = require 'kd-react'
EnvironmentFlux = require 'app/flux/environment'
KDReactorMixin  = require 'app/flux/base/reactormixin'
View            = require './view'
SidebarFlux = require 'app/flux/sidebar'


module.exports = class TeamStacksListContainer extends React.Component

  getDataBindings: ->
    return {
      templates: EnvironmentFlux.getters.inUseTeamStackTemplates
      sidebarStacks: SidebarFlux.getters.sidebarStacks
    }


  onAddToSidebar: (stackTemplateId) -> EnvironmentFlux.actions.generateStack stackTemplateId


  onRemoveFromSidebar: (stackTemplateId) -> EnvironmentFlux.actions.deleteStack stackTemplateId


  render: ->
    <View
      templates={@state.templates}
      sidebarStacks={@state.sidebarStacks}
      onOpenItem={@props.onOpenItem}
      onAddToSidebar={@bound 'onAddToSidebar'}
      onRemoveFromSidebar={@bound 'onRemoveFromSidebar'}
    />

TeamStacksListContainer.include [KDReactorMixin]

