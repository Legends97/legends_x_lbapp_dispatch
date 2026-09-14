// Track if the user clicked the message button
let isMessageButtonClicked = false;
let job = 'ambulance';

// Button to open the message screen
document.getElementById('message-button').addEventListener('click', () => {
  isMessageButtonClicked = true; // Set to true when this button is clicked
  document.getElementById('screen1').style.display = 'none';
  document.getElementById('screen2').style.display = 'block';
});

// Button to open the call screen
document.getElementById('call-button').addEventListener('click', () => {
  isMessageButtonClicked = false; // Set to false when this button is clicked
  document.getElementById('screen1').style.display = 'none';
  document.getElementById('screen2').style.display = 'block';
});

// Handle emergency type selection
document.querySelectorAll('.emergency-type').forEach(button => {
  button.addEventListener('click', function() {
    const department = this.getAttribute('data-value');
    job = department;
    document.getElementById('screen2').style.display = 'none';
    
    // Show the correct screen based on the button clicked
    if (isMessageButtonClicked) {
      document.getElementById('screen3').style.display = 'block'; // Show message screen
    } else {
      document.getElementById('screen4').style.display = 'block'; // Show call screen
    }
  });
});

// Define the returnToScreen1 function
function returnToScreen1() {
  document.getElementById('screen3').style.display = 'none';
  document.getElementById('screen4').style.display = 'none';
  document.getElementById('screen1').style.display = 'block';
}

// Sending message logic
document.getElementById('send-message').addEventListener('click', () => {
  const message = document.getElementById('message').value.trim();
  
  if (message === '') {
    alert("Bitte eine Nachricht eingeben!");
    return;
  }

  // Assume department is set based on the last selected emergency type
  //const department = // retrieve the department from the previously selected button
  fetch(`https://mfp_lb-dispatches/sendEmergencyMessage`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ job, message }),
  });
});

// Logic for making a call
document.getElementById('make-call').addEventListener('click', () => {
  // Assume department is set based on the last selected emergency type
  //const department = // retrieve the department from the previously selected button
  fetch(`https://mfp_lb-dispatches/callEmergencyHotline`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ job }),
  });
});