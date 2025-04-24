function askForEmail() {
  // Check if email is already in local storage
  //let storedEmail = localStorage.getItem('email');
  //if (storedEmail) {
    //return;
  //}

  // Jokes array
  const jokes = [
    "Why don't scientists trust atoms? \nBecause they make up everything!  \n\nDon't miss out on any of the crazy, grant me your semi-precious email.",
    "Why did the scarecrow win an award? \nBecause he was outstanding in his field! \n\nTo help me track you creepily, grant me your semi-precious email.",
    "Why did the bicycle fall over? \nBecause it was two tired! \n\nTo ensure you receive one million dollars, grant me your semi-precious email.",
    "What do you call a fish with no eyes? \n Fsh! \n\nTo stay connected and receive absolutely no exclusive offers, grant me your semi-precious email.",
    "Why did the coffee go to the police? \nIt got mugged! \n\nTo keep you informed about my escapades, grant me your semi-precious email.",
    "What did the left eye say to the right eye? \nBetween you and me, something smells! \n\nTo provide you with the worst possible experience, grant me your email below.",
    "Why did the golfer wear two pairs of pants? \nIn case he got a hole-in-one! \n\nTo tailor my services to your undying needs, grant me your semi-precious email.",
    "What do you call a lazy kangaroo? \nA pouch potato! \n\nTo ensure you never miss a beat, grant me your semi-precious email.",
    "Why did the math book look so sad? \nBecause it had too many problems!  \n\nTo help me default AI, grant me your semi-precious email.",
    "What did the buffalo say when his son left for college? \nBison! \n\nTo continue providing you with valuable content and make enough money for dinner, grant me your semi-precious email.",
    "What do you call a bear with no teeth? \nA gummy bear! \n\nTo show your appreciation, grant me your semi-precious email."
  ];

  // Select a random joke
  let joke = jokes[Math.floor(Math.random() * jokes.length)];
  let optOut = "\n\nYou can refuse to provide your email by entering anything else, such as 'no' or '**die robots!**' or even 'fffffff nooooooo!'";
  let annoyUser = joke + optOut + " : \n\n";

  // Prompt for email
  let value = prompt(annoyUser);

  captureEmail(value);
};

function captureEmail(value){
  if (value) {
    localStorage.setItem('email', value);

    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    console.log('captureEmail', value);

    if (re.test(value)) {
      gtag('event', 'email_provided', {
        'event_category': 'engagement',
        'event_label': value
      });
      alert(`🙏 - got it '${value}'! chat soon!`);
    } else {
      gtag('event', 'email_refused', {
        'event_category': 'engagement',
        'event_label': value
      });
      alert(`'${value}'!? - 🫡 - go it!`);
    }

  }
};

const emailValue = document.getElementById('emailValue');
const emailSubmit = document.getElementById('emailSubmit'); // Replace 'submitButton' with your button's ID

if(emailSubmit){
  emailSubmit.addEventListener('click', function() {
    if (emailValue.value.trim() !== '') {
      captureEmail(emailValue.value.trim());
      emailValue.value = '';
    }
  });
}


// Call the function to ask for email
//askForEmail();
