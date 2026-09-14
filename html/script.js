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
  document.getElementById('screen5').style.display = 'none';
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

// ---- Active dispatch queue (job members) ----

document.getElementById('dispatch-button').addEventListener('click', () => {
  document.getElementById('screen1').style.display = 'none';
  document.getElementById('screen5').style.display = 'block';
});

document.getElementById('dispatch-back').addEventListener('click', returnToScreen1);

function updateDispatchEmptyState() {
  const list = document.getElementById('dispatch-list');
  document.getElementById('dispatch-empty').style.display = list.children.length === 0 ? 'block' : 'none';
}

function renderDispatchCard(dispatch) {
  const card = document.createElement('div');
  card.className = 'dispatch-card';
  card.dataset.id = dispatch.id;
  card.innerHTML = `
    <div class="dispatch-card-header">
      <span class="dispatch-title"></span>
      <span class="dispatch-time"><i class="fas fa-clock"></i> ${dispatch.time}</span>
    </div>
    <div class="dispatch-postal"><i class="fas fa-map-marker-alt"></i> Postal <span class="dispatch-postal-value"></span></div>
    <div class="dispatch-actions">
      <button class="dispatch-decline">Ablehnen</button>
      <button class="dispatch-accept">Annehmen</button>
    </div>
  `;
  card.querySelector('.dispatch-title').textContent = dispatch.title;
  card.querySelector('.dispatch-postal-value').textContent = dispatch.postal;

  card.querySelector('.dispatch-accept').addEventListener('click', () => {
    fetch(`https://mfp_lb-dispatches/app:accept`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: dispatch.id }),
    });
    removeDispatchCard(dispatch.id);
  });

  card.querySelector('.dispatch-decline').addEventListener('click', () => {
    fetch(`https://mfp_lb-dispatches/app:decline`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: dispatch.id }),
    });
    removeDispatchCard(dispatch.id);
  });

  return card;
}

function addOrUpdateDispatchCard(dispatch) {
  removeDispatchCard(dispatch.id);
  document.getElementById('dispatch-list').appendChild(renderDispatchCard(dispatch));
  updateDispatchEmptyState();
}

function removeDispatchCard(id) {
  const card = document.querySelector(`.dispatch-card[data-id="${id}"]`);
  if (card) card.remove();
  updateDispatchEmptyState();
}

function setDispatches(dispatches) {
  document.getElementById('dispatch-list').innerHTML = '';
  dispatches.forEach(addOrUpdateDispatchCard);
  updateDispatchEmptyState();
}

window.addEventListener('message', (event) => {
  const data = event.data;

  if (data.action === 'addDispatch') {
    addOrUpdateDispatchCard(data.dispatch);
  } else if (data.action === 'removeDispatch') {
    removeDispatchCard(data.id);
  } else if (data.action === 'setDispatches') {
    setDispatches(data.dispatches);
  }
});

fetch(`https://mfp_lb-dispatches/app:ready`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({}),
})
  .then((resp) => resp.json())
  .then((res) => {
    if (res && res.isDispatchJob) {
      document.getElementById('dispatch-button').style.display = 'block';
    }
  });

updateDispatchEmptyState();