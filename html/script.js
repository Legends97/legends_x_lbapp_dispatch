// Only reachable inside FiveM's NUI - avoids hanging fetches when previewing this file in a plain browser
const inGame = typeof window.invokeNative === 'function';

function callApp(endpoint, body) {
  if (!inGame) return Promise.resolve({});

  return fetch(`https://mfp_lb-dispatches/${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body || {}),
  }).then((resp) => resp.json());
}

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
    callApp('app:accept', { id: dispatch.id });
    removeDispatchCard(dispatch.id);
  });

  card.querySelector('.dispatch-decline').addEventListener('click', () => {
    callApp('app:decline', { id: dispatch.id });
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

callApp('app:ready', {});
updateDispatchEmptyState();
