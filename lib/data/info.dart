
const info = [
  {
    'name': 'Rivaan Ranawat',
    'messages' : lastMessages,
    'isPinned': false,
    'isNotificationMute': false,
    'profileUrl':
        'https://upload.wikimedia.org/wikipedia/commons/8/85/Elon_Musk_Royal_Society_%28crop1%29.jpg',
  },
  {
    'name': 'John Doe',
    'messages' : lastMessages,
    'isPinned': true,
    'isNotificationMute': false,
    'profileUrl':
        'https://www.socialketchup.in/wp-content/uploads/2020/05/fi-vill-JOHN-DOE.jpg',
  },
  {
    'name': 'Naman Ranawat',
    'messages' : lastMessages,
    'isPinned': false,
    'isNotificationMute': true,
    'profileUrl':
        'https://media.cntraveler.com/photos/60596b398f4452dac88c59f8/16:9/w_3999,h_2249,c_limit/MtFuji-GettyImages-959111140.jpg',
  },
  {
    'name': 'Dad',
    'messages' : lastMessages,
    'isPinned': true,
    'isNotificationMute': true,
    'profileUrl':
        'https://pbs.twimg.com/profile_images/1419974913260232732/Cy_CUavB.jpg',
  },
  {
    'name': 'Mom',
    'messages' : lastMessages,
    'isPinned': false,
    'isNotificationMute': true,
    'profileUrl':
        'https://uploads.dailydot.com/2018/10/olli-the-polite-cat.jpg?auto=compress%2Cformat&ixlib=php-3.3.0',
  },
  {
    'name': 'Jurica',
    'messages' : lastMessages,
    'isPinned': true,
    'isNotificationMute': false,
    'profileUrl':
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cmFuZG9tJTIwcGVvcGxlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
  },
  {
    'name': 'Albert Dera',
    'messages' : lastMessages,
    'isPinned': false,
    'isNotificationMute': false,
    'profileUrl':
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8cmFuZG9tJTIwcGVvcGxlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
  },
  {
    'name': 'Joseph',
    'messages' : lastMessages,
    'isPinned': true,
    'isNotificationMute': false,
    'profileUrl':
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8cmFuZG9tJTIwcGVvcGxlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
  },
  {
    'name': 'Sikandar',
    'messages' : lastMessages,
    'isPinned': false,
    'isNotificationMute': true,
    'profileUrl':
        'https://images.unsplash.com/photo-1619194617062-5a61b9c6a049?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHJhbmRvbSUyMHBlb3BsZXxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
  },
  {
    'name': 'Ian Dooley',
    'messages' : lastMessages,
    'isPinned': true,
    'isNotificationMute': true,
    'profileUrl':
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8cmFuZG9tJTIwcGVvcGxlfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=900&q=60',
  },
];

const lastMessages = [
  {"type": "received", "data": "Hey What is up with you!!", "time": 98, "state": "null",},
  {"type": "sent", "data": "im fine,wbu?", "time": 99, "state": "viewed"},
  {"type": "received", "data": "I am great man!", "time": 100, "state": "null",},
  {
    "type": "received",
    "data": "Just lastMessaged cuz I had some work.",
    "time": 101, "state": "null",
  },
  {"type": "sent", "data": "Obviously, say", "time": 102, "state": "viewed"},
  {
    "type": "received",
    "data": "haha I wanted you to check out my new channel ^^",
    "time": 103, "state": "null",
  },
  {
    "type": "sent",
    "data": " Sure, what is the channel name?",
    "time": 104, "state": "received"
  },
  {
    "type": "received",
    "data": "Rivaan Ranawat",
    "time": 105,
    "state": "null",
  },
  {
    "type": "sent",
    "data": "Looks great to me!",
    "time": 106,
    "state": "received"
  },
  

  {"type": "received", "data": "Thanks bro!", "time": 1111, "state": "null",},
  {
    "type": "received",
    "data": "Did you subscribe?",
    "time": 107, "state": "null",
  },
  {
    "type": "sent",
    "data": "Yes, surely bro!",
    "time": 108, "state": "sent"
  },
  {
    "type": "received",
    "data": "Cool, did you like the content?",
    "time": 109,
    "state": "null",
  },
  {
    "type": "sent",
    "data": "I loved it?",
    "time": 110,
    "state": "waiting"
  },
  {
    "type": "received",
    "data": "OMG! Woah! Thanks!",
    "time": 111,
    "state": "null",
  },
  {
    "type": "received",
    "data": "OMG! \nWoahhhh! \nThanks!",
    "time": 111,
    "state": "null",
  },
  {
    "type": "received",
    "data": "Hello how are you what are you dosi al so wl a;en vala oe laldw lwo d  mucho gusto lo siento hola laoow lafeohow l codls wojel ",
    "time": 112,
    "state": "null",
  },
  {
    "type": "sent",
    "data": "Hello how are you what are you dosi al so wl a;en vala oe laldw lwo d  mucho gusto lo siento hola laoow lafeohow l codls wojel laoow lafeohow l",
    "time": 112,
    "state": "failed"
  },
];