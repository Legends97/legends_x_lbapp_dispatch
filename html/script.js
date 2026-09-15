// LB-Phone injects fetchNui/onNuiEvent into the custom-app iframe - only reachable there,
// not when previewing this file in a plain browser
const inGame = typeof window.fetchNui === 'function';

function callApp(endpoint, body) {
  if (!inGame) return Promise.resolve({});

  return fetchNui(endpoint, body || {});
}

// German defaults for browser preview / before app:ready resolves - overwritten by Config.Locale in-game
let i18n = {
  onDuty: 'Im Dienst',
  noActiveDispatches: 'Keine aktiven Notrufe',
  accept: 'Annehmen',
  decline: 'Ablehnen',
  postal: 'Postal',
};

function applyI18n(res) {
  if (res.appName) document.getElementById('app-title').textContent = res.appName;
  if (res.i18n) i18n = res.i18n;

  document.getElementById('app-status-text').textContent = i18n.onDuty;
  document.getElementById('dispatch-empty').textContent = i18n.noActiveDispatches;
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
    <div class="dispatch-postal"><i class="fas fa-map-marker-alt"></i> <span class="dispatch-postal-label"></span> <span class="dispatch-postal-value"></span></div>
    <div class="dispatch-actions">
      <button class="dispatch-decline"></button>
      <button class="dispatch-accept"></button>
    </div>
  `;
  card.querySelector('.dispatch-title').textContent = dispatch.title;
  card.querySelector('.dispatch-postal-label').textContent = i18n.postal;
  card.querySelector('.dispatch-postal-value').textContent = dispatch.postal;
  card.querySelector('.dispatch-decline').textContent = i18n.decline;
  card.querySelector('.dispatch-accept').textContent = i18n.accept;

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

if (inGame) {
  onNuiEvent('addDispatch', addOrUpdateDispatchCard);
  onNuiEvent('removeDispatch', removeDispatchCard);
  onNuiEvent('setDispatches', setDispatches);
}

callApp('app:ready', {}).then((res) => {
  applyI18n(res);
});
applyI18n({});
updateDispatchEmptyState();
