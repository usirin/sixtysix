jest.autoMockOff()

Router = require '../src/router'

router = null
beforeTests = (options) ->

  Router.cleanPageRouter()
  router = new Router options

tests = -> describe 'Router', ->

  beforeEach -> beforeTests()

  it 'works', ->

    expect(router).toBeDefined()

  it 'has defaults', ->

    expect(router.routes).toEqual {}
    expect(router.exitRoutes).toEqual {}
    expect(router.defaultRoute).toEqual '/'
    expect(router.basePath).toEqual ''


  describe '#addRoute', ->

    it 'registers route', ->

      handler = -> flag = on

      router.addRoute '/foo', handler

      expect(router.routes['/foo'][0]).toBe handler


  describe '#addRoutes', ->

    it 'registers multiple routes', ->

      router.addRoutes
        '/foo': foo = -> 'foo'
        '/bar': bar = -> 'bar'

      expect(router.routes['/foo'][0]).toBe foo
      expect(router.routes['/bar'][0]).toBe bar


  describe '#handleRoute', ->

    beforeEach -> beforeTests()

    it 'executes the route listeners when listening', ->

      flag = off
      router.addRoute '/foo', -> flag = on

      router.handleRoute '/foo'
      expect(flag).toBe on


    it 'gets params from first parameter of callback', ->

      expected = null
      router.addRoute '/user/:id', ({ params }) ->

        { id } = params
        expected = id

      router.listen()

      router.handleRoute '/user/3'

      expect(expected).toBe '3'

    it 'calls global callbacks if registered', ->

      flag = off
      router.addRoute '*', -> flag = on

      router.listen()

      router.handleRoute '/foo'

      expect(flag).toBe on

    it "doesn't call multiple callbacks", ->

      count = 0
      router.addRoute '/multiple', -> count = count + 1
      router.addRoute '/multiple', -> count = count + 2

      router.listen()

      router.handleRoute '/multiple'
      expect(count).toBe 1


  describe '#exitRoute', ->

    it 'adds a callback to be called when leaving a route', ->

      flag = off
      router.addRoute '/exittest', -> flag = on
      router.exitRoute '/exittest', -> flag = off

      router.listen()

      router.handleRoute '/exittest'
      expect(flag).toBe on

      router.handleRoute '/'
      expect(flag).toBe off


  describe '#back', ->

    it 'navigates back', ->

      router
        .addRoute('/first', ->)
        .addRoute('/second', ->)
        .listen()
        .handleRoute '/first'
        .handleRoute '/second'
        .back()

      expect(location.pathname).toBe '/first'


  describe '#forward', ->

    it 'navigates forward', ->

      router
        .addRoute('/first', ->)
        .addRoute('/second', ->)
        .listen()
        .handleRoute '/first'
        .handleRoute '/second'
        .back()
        .forward()

      expect(location.pathname).toBe '/second'


  describe '#getCurrentPath', ->

    it 'returns current path', ->

      router
        .addRoute('/route66', ->)
        .listen()
        .handleRoute '/route66'

      currentPath = router.getCurrentPath()
      expect(currentPath).toBe '/route66'


  describe '#clear', ->

    it 'replaces path with default route', ->

      router
        .addRoute('/beginning', ->)
        .addRoute('/replacable', ->)
        .addRoute('/', ->)
        .listen()
        .handleRoute '/beginning'
        .handleRoute '/replacable'
        .clear()

      expect(location.pathname).toBe '/'

      router.back()
      expect(location.pathname).toBe '/beginning'


  describe '#replaceRoute', ->

    it 'replaces route with changing the current history entry', ->

      router
        .addRoute('/beginning', ->)
        .addRoute('/replacable', ->)
        .addRoute('/awesome-route', ->)
        .listen()
        .handleRoute '/beginning'
        .handleRoute '/replacable'
        .replaceRoute '/awesome-route'

      expect(location.pathname).toBe '/awesome-route'

      router.back()
      expect(location.pathname).toBe '/beginning'

  describe '#redirect', ->

    it 'redirects', (done) ->

      router
        .addRoute('/beginning', ->)
        .addRoute '/awesome-route', -> done()
        .listen()
        .handleRoute '/beginning'
        .redirect '/awesome-route'


afterTests = ->

  Router.getPageRouter().base ''

describe 'FirstSuite', ->

  beforeEach -> beforeTests()

  tests()

  afterEach -> afterTests()


describe 'Second suite with different base path', ->

  beforeEach -> beforeTests { basePath: '/ultra-awesome-super-path' }

  tests()

  afterEach -> afterTests()


