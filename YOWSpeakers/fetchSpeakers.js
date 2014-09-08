var speakerTags = document.querySelectorAll('.span2 > div')

speakers = []

for (var i = 0; i < speakerTags.length; i++) {
  var speaker = speakerTags[i]
  var name = speaker.querySelector('h4 a').textContent
  var title = speaker.querySelector('.spk_title').textContent
  var avatarURL = speaker.querySelector('.speaker_image img').getAttribute('src')
  speakers.push({"speakerName" : name, "speakerTitle" : title, "avatarURL" : avatarURL})
}

webkit.messageHandlers.didFetchSpeakers.postMessage(speakers)