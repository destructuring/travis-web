require 'travis/expandable_record_array'
require 'travis/model'

@Travis.Repo = Travis.Model.extend
  id:                  Ember.attr('string')
  slug:                Ember.attr('string')
  description:         Ember.attr('string')
  private:             Ember.attr('boolean')
  lastBuildId:         Ember.attr('string')
  lastBuildNumber:     Ember.attr(Number)
  lastBuildState:      Ember.attr('string')
  lastBuildStartedAt:  Ember.attr('string')
  lastBuildFinishedAt: Ember.attr('string')
  githubLanguage:      Ember.attr('string')
  _lastBuildDuration:  Ember.attr(Number, key: 'last_build_duration')

  lastBuild: Ember.belongsTo('Travis.Build', key: 'last_build_id')

  lastBuildHash: (->
    {
      id: @get('lastBuildId')
      number: @get('lastBuildNumber')
      repo: this
    }
  ).property('lastBuildId', 'lastBuildNumber')

  allBuilds: (->
    recordArray = Ember.RecordArray.create({ modelClass: Travis.Build, content: Ember.A([]) })
    Travis.Build.registerRecordArray(recordArray)
    recordArray
  ).property()

  builds: (->
    id = @get('id')
    builds = Travis.Build.byRepoId id, event_type: 'push'

    # TODO: move to controller
    array  = Travis.ExpandableRecordArray.create
      type: Travis.Build
      content: Ember.A([])

    array.load(builds)

    id = @get('id')
    array.observe(@get('allBuilds'), (build) -> build.get('isLoaded') && build.get('repo.id') == id && !build.get('isPullRequest') )

    array
  ).property()

  pullRequests: (->
    id = @get('id')
    builds = Travis.Build.byRepoId id, event_type: 'pull_request'
    array  = Travis.ExpandableRecordArray.create
      type: Travis.Build
      content: Ember.A([])

    array.load(builds)

    id = @get('id')
    array.observe(@get('allBuilds'), (build) -> build.get('isLoaded') && build.get('repo.id') == id && build.get('isPullRequest') )

    array
  ).property()

  branches: (->
    Travis.Build.branches repoId: @get('id')
  ).property()

  events: (->
    Travis.Event.byRepoId @get('id')
  ).property()

  owner: (->
    (@get('slug') || '').split('/')[0]
  ).property('slug')

  name: (->
    (@get('slug') || '').split('/')[1]
  ).property('slug')

  lastBuildDuration: (->
    duration = @get('_lastBuildDuration')
    duration = Travis.Helpers.durationFrom(@get('lastBuildStartedAt'), @get('lastBuildFinishedAt')) unless duration
    duration
  ).property('_lastBuildDuration', 'lastBuildStartedAt', 'lastBuildFinishedAt')

  sortOrder: (->
    # this is prepared for ascending sort
    if Ember.isNone(@get('lastBuildFinishedAt')) && @get('lastBuildStartedAt')
      # if a build is running, it should be at the beginning
      0
    else if lastBuildStartedAt = @get('lastBuildStartedAt')
      # if it's not running, but was already run, put newest builds first
      new Date('9999').getTime() - Date.parse(lastBuildStartedAt)
    else
      # if it's not started nor it was ran before, sort with newest id first
      new Date('9999').getTime() - @get('id')
  ).property('lastBuildFinishedAt', 'id', 'lastBuildStartedAt')

  stats: (->
    if @get('slug')
      @get('_stats') || $.get("https://api.github.com/repos/#{@get('slug')}", (data) =>
        @set('_stats', data)
        @notifyPropertyChange 'stats'
      ) && {}
  ).property('slug')

  updateTimes: ->
    @notifyPropertyChange 'lastBuildDuration'

  regenerateKey: (options) ->
    Travis.ajax.ajax '/repos/' + @get('id') + '/key', 'post', options

@Travis.Repo.reopenClass
  recent: ->
    @find()

  ownedBy: (login) ->
    @find(owner_name: login, orderBy: 'name')

  accessibleBy: (login) ->
    @find(member: login, orderBy: 'name')

  search: (query) ->
    @find(search: query, orderBy: 'name')

  withLastBuild: ->
    filtered = Ember.FilteredRecordArray.create(
      modelClass: Travis.Repo
      filterFunction: (repo) -> repo.get('lastBuildId')
      filterProperties: ['lastBuildId']
    )

    Travis.Repo.fetch().then (array) ->
      filtered.updateFilter()
      filtered.set('isLoaded', true)

    filtered

  bySlug: (slug) ->
    repo = $.select(@find().toArray(), (repo) -> repo.get('slug') == slug)
    if repo.length > 0 then repo else @find(slug: slug)

  fetchBySlug: (slug) ->
    repos = $.select(@find().toArray(), (repo) -> repo.get('slug') == slug)
    if repos.length > 0
      repos[0]
    else
      @fetch(slug: slug).then (repos) -> Ember.get(repos, 'firstObject')

  # buildURL: (slug) ->
  #   if slug then slug else 'repos'
