

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
@VideosPages = new Meteor.Pagination Videos,
  perPage: 20
  itemTemplate: "video"
  templateName: "videoPages"  


Router.configure
  layoutTemplate: 'layout'
    

Meteor.startup ->
  Router.map -> 
    @route "index",
      path: "/"
      template: "videoSearch"
      data:
        user: ->
          Meteor.user()
      waitOn: -> 
        Meteor.subscribe 'allVideos'

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
      Videos.find {title:{$regex:searchWords,$options:"i"}}

  Template.search.events
    "change #searchWords": (e) ->
      e.stopPropagation()
      newSearchWords = $(e.target).val()
      Session.set("searchWords",newSearchWords)
      # console.log e
      # console.log $(e.target).val()

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
  Meteor.publish "allVideos", ->
    Videos.find()

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