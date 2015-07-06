'use strict'

App = require('./app')

module.exports =
  author: 'darth.vader@navercorp.com'
  name: 'sample game'
  template: 'game/sample/view/sample.controller.html'
  controller: 'GameSampleController'
  factory: (sockets) ->

    console.log '>>> sockets'

    # console.log sockets

    setTimeout ->

      sockets.emit 'message', '>>> enter room : ' + parseInt(Math.random() * 10, 10)
      console.log 'emit message'
    , 2000
    mighty = new App.Mighty()

    instance =
      onenter: (socket) ->

        console.log '>>> mighty entered'


        player = new App.Player(socket)
        # player2 = new App.Player({id: '1st'})
        # player3 = new App.Player({id: '3rd'})
        # player4 = new App.Player({id: '4th'})
        # player5 = new App.Player({id: '5th'})
        mighty.join player, (err, result) ->
          broadcast()
          # mighty.join player2, (err, result) ->
          #   mighty.join player3, (err, result) ->
          #     mighty.join player4, (err, result) ->
          #       mighty.join player5, (err, result) ->
          #         broadcast()
          # if err
          #   callback err
          # else
          #   callback null, id: player.id
          #   broadcast()

          # setTimeout ->
          # broadcast()
          # , 1000


        # console.log mighty


      onleave: (socket) ->

        console.log '>>> exit'

        for player in mighty.players
          if player.socket.id is socket.id
            targetPlayer = player
            break

        console.log '>>> exit target player'
        console.log targetPlayer
        if targetPlayer

          mighty.leave player, (err, result) ->
            broadcast()

        # console.log '>>> mighty exit'





    

    instance