require! multimethod

module.exports = (f = ->it) ->
    mm = multimethod (a,b) -> [f(a), f(b)]
    [_dispatch,_when] = mm<[dispatch when]>
    mm.dispatch = (f) ->
        _dispatch (a,b) -> [f(a), f(b)]
        mm
    mm.when = (a,b,f) ->
        _when [a,b], f
        _when [b,a], (b,a) -> f a,b
        mm
    mm