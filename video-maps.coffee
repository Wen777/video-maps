
@nPerPageDefault = 40
@nPerPage = nPerPageDefault

youtubeVideos = [
  {_id:"OCQU6M4pPiw", title:"r basic"},
  {_id:"xt1_oXJtB3M", title:"machine learning"},
  {_id:"hIdvjh-O69w", title:"r advanced"},
  {_id:"vteHJEJuNcQ", title:"1234"},
  {_id:"CLq8MlK3oo0", title:"learning r"},
  {_id:"A1IIcZW5UrI", title:"dboy"},
  {_id:"9K3B3OYMtjY", title:"dboy 1234"},
  {_id:"escsixrqG6M", title:"machine gun"},
  
]

@Videos = new Meteor.Collection "ytVideos"

# console.log "Meteor.Pagination = "
# console.log Meteor.Pagination
# console.log Meteor.Pagination::

@VideosPages = new Meteor.Pagination Videos,
  perPage: 20
  itemTemplate: "video"
  templateName: "videoPages"  


Meteor.methods
  "countNVideos": (query) ->
    if not query
      query = {}

    console.log "Videos.find(query).count() = "
    console.log Videos.find(query).count()
    
    Videos.find(query).count()


Router.configure
  layoutTemplate: 'layout'
    

Meteor.startup ->
  Router.map -> 
    @route "allVideos",
      path: "/allVideos"
      template: "allVideos"

    @route "index",
      path: "/"
      template: "videoSearch"
      data:

        user: ->
          Meteor.user()
      waitOn: -> 
        # # searchWords = Session.get("searchWords")
        # # if not searchWords
        # #   Session.set("searchWords", ".*")
        # #   searchWords = Session.get("searchWords")

        # nVideoPerPage = Session.get("nVideoPerPage")
        # if not nVideoPerPage
        #   Session.set("nVideoPerPage", 40)
        #   nVideoPerPage = Session.get("nVideoPerPage")

        # mPage = Session.get("mPage")
        # if not mPage
        #   Session.set("mPage", 1)
        #   mPage = Session.get("mPage")

        Meteor.subscribe 'allVideos'
 
    @route "videos",
      path: "videos/:page?"
      template: "videoSearch"
      data:
        isVideos: true

        user: ->
          Meteor.user()
        countNVideos: ->
          Session.get("countNVideos")

        mPage: ->
          Session.get("mPage")

        startIdx: ->
          mPage = Session.get("mPage")
          mPage*nPerPage + 1
        endIdx: -> 
          mPage = Session.get("mPage")
          (mPage+1)*nPerPage 
        nextPage: ->
          mPage = Session.get("mPage")
          String(mPage + 1)
        prevPage: ->
          mPage = Session.get("mPage")
          if mPage - 1 < 0 then "0" else String(mPage - 1)
          
            

      waitOn: -> 
        mPage = parseInt(@params.page) || 0
        Session.set("mPage", mPage)

        searchWords = Session.get("searchWords")
        if not searchWords
          Session.set("searchWords", ".*")
          searchWords = Session.get("searchWords")

        qeury = {title:{$regex:searchWords,$options:"i"}}

        Meteor.subscribe 'allVideos', mPage, nPerPage, qeury
        Meteor.call "countNVideos", qeury, (err, res) -> 
          Session.set("countNVideos", res)
          

    @route "videoSearch",
      path: "/videoSearch"
      template: "videoSearch"
      data:
        user: ->
          Meteor.user()
      
      waitOn: -> 
        Meteor.subscribe 'allVideos'




if Meteor.isClient
  Session.setDefault("searchWords",".*")

  Template.videoList.helpers
    # helloTemp: "hello template"
    # helloArray: [{text:"abc"},{text:"fsdfs"},{text:"fsg"}]
    # helloObject: 
    #   name: "test"
    #   data: [{text:"abc"},{text:"fsdfs"},{text:"fsg"}]
    
    # videoList: youtubeVideos

    videoList: -> 
      searchWords = Session.get("searchWords")
      Videos.find {title:{$regex:searchWords,$options:"i"}}, {limit:40}
      # Videos.find()

  Template.search.events
    "change #searchWords": (e) ->
      e.stopPropagation()
      newSearchWords = $(e.target).val()
      Session.set("searchWords",newSearchWords)
      Router.go 'videos', page:"0"
      # console.log e
      # console.log $(e.target).val()


  Template.search.helpers
    nVideoPerPage: ->
      Session.get("nVideoPerPage")

  # Template.video.rendered = ->
  #   # console.log @data._id
  #   video = Popcorn.youtube("#"+@data._id, 'http://www.youtube.com/embed/'+@data._id)
  
  Template.video.rendered = ->
    $("video").map -> 
      videojs @, JSON.parse($(@).attr("data-setup")) 


# if Meteor.isServer
#   if Videos.find().count() is 0
#     Videos.insert xx for xx in youtubeVideos

if Meteor.isServer
  Meteor.publish "allVideos", (mPage, nPerPage, qeury) ->
    
    # totalVideos = Videos.find({title:{$regex:searchWords,$options:"i"}}).count()

    # if nVideoPerPage < totalVideos
    #   mPage = 0 
    #   kSkips = nVideoPerPage*mPage
    # else
    #   kSkips = nVideoPerPage*mPage
    #   while kSkips >= totalVideos
    #     kSkips = kSkips - totalVideos

    #   while kSkips < 0 
    #     kSkips = kSkips + totalVideos
    if not nPerPage
      nPerPage = nPerPageDefault

    if not mPage
      mPage = 0 
    
    if not qeury
      qeury = {}

    kSkips = nPerPage*mPage
    console.log "kSkips = "
    console.log kSkips

    Videos.find qeury, {skip:kSkips, limit:nPerPage}

  Accounts.onCreateUser (options, user) ->

    console.log "user.services.meetup = "
    console.log user.services.meetup
    console.log user.services.meetup.id

    userMeetupId = String(user.services.meetup.id)
    userMeetupToken = user.services.meetup.accessToken

    userProfileUrl = "https://api.meetup.com/2/member/" + userMeetupId + "?&sign=true&photo-host=public&access_token=" + userMeetupToken

    console.log "userProfileUrl = "
    console.log userProfileUrl

    # userApiData = {}

    res = Meteor.http.call "GET", userProfileUrl
    # , {}, (error, response)->
    #   if not error
    #     # console.log "response = "
    #     console.log JSON.parse(response.content)
    #     # userApiData JSON.parse(response.content)
    #     resData = JSON.parse(response.content)
    #     userApiData.photo = resData.photo
    #     user.meetupApiData = resData

    # console.log "userApiData = "
    # console.log userApiData




    # console.log "res = "
    # console.log res
    # console.log typeof res.content
    # console.log typeof JSON.parse res.content
    resData = JSON.parse res.content
    
    user.services.meetup.apiData = {}
    _.extend user.services.meetup.apiData, resData 

    user.profile = {}

    user.profile.name = resData.name
    user.profile.hometown = resData.hometown
    user.profile.photo = resData.photo
    user.profile.link = resData.link
    user.profile.city = resData.city
    user.profile.country = resData.country
    user.profile.joined = resData.joined
    user.profile.topics = resData.topics
    user.profile.other_services = resData.other_services
    




    user


#     # if user.profile
#     #   origin = user.services.facebook
#     #   target = user.profile 
#     #   allow_fields = ["email","last_name","first_name","gender","id","locale","link"]
#     #   ((key)-> target[key]=origin[key])(one_key) for one_key in Object.keys(origin) when one_key in allow_fields
#     #   target.picture = "http://graph.facebook.com/" + target.id + "/picture/?type=large"
#     # else
#     #   user.profile = {}
#     #   origin = user.services.facebook
#     #   target = user.profile 
#     #   allow_fields = ["email","last_name","first_name","gender","id","locale","link"]
#     #   ((key)-> target[key]=origin[key])(one_key) for one_key in Object.keys(origin) when one_key in allow_fields
#     #   target.picture = "http://graph.facebook.com/" + target.id + "/picture/?type=large"
    
#     user  