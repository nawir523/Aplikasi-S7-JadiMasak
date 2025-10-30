/* -------------------------
   Dummy data (MVP)
   ------------------------- */
const RECIPES = [
  {id:'r1',title:'Nasi Goreng Sederhana',category:'Makanan Utama',image:'',ingredients:['2 piring nasi putih','2 butir telur','2 sdm kecap manis','1 sdm minyak','1 siung bawang putih'],steps:['Panaskan minyak, tumis bawang hingga harum.','Masukkan telur, orak-arik.','Tambahkan nasi dan kecap, aduk rata.','Sajikan hangat.']},
  {id:'r2',title:'Telur Dadar Praktis',category:'Sarapan',image:'',ingredients:['2 butir telur','Garam secukupnya','1 sdm minyak'],steps:['Kocok telur + garam.','Panaskan minyak, tuang telur.','Goreng hingga matang.']},
  {id:'r3',title:'Mie Goreng Cepat',category:'Mie',image:'',ingredients:['1 bungkus mie instan','1 butir telur','Sayur secukupnya'],steps:['Rebus mie lalu tiriskan.','Tumis sayur, masukkan mie & bumbu.','Masak sebentar, sajikan.']},
  {id:'r4',title:'Tumis Sayur Simple',category:'Sayur',image:'',ingredients:['Sayur campur 200gr','2 siung bawang putih','Garam & merica'],steps:['Tumis bawang putih hingga harum.','Masukkan sayur, tambahkan garam.','Masak hingga layu.']},
  {id:'r5',title:'Smoothie Pisang',category:'Minuman',image:'',ingredients:['1 buah pisang','150ml susu','Es batu secukupnya'],steps:['Masukkan semua bahan ke blender.','Blend hingga halus.','Tuang dan sajikan.']}
];

/* -------------------------
   App state & helpers
   ------------------------- */
const State = {
  recipes: RECIPES.slice(),
  categories: [],
  activeCategory: 'Semua',
  query: '',
  favorites: new Set(JSON.parse(localStorage.getItem('jm_favs') || '[]'))
};

function saveFavs(){ 
  localStorage.setItem('jm_favs', JSON.stringify(Array.from(State.favorites))); 
}

/* -------------------------
   View helpers
   ------------------------- */
const screens = {
  splash: document.getElementById('splash'),
  home: document.getElementById('home'),
  detail: document.getElementById('detail'),
  favorites: document.getElementById('favorites')
};

function showScreen(name){
  Object.values(screens).forEach(s=>s.classList.remove('active'));
  screens[name].classList.add('active');
  Object.keys(screens).forEach(k => screens[k].setAttribute('aria-hidden', k!==name));
}

/* ----- build categories ----- */
function initCategories(){
  const cats = new Set(State.recipes.map(r=>r.category));
  State.categories = ['Semua', ...Array.from(cats)];
}

/* ----- render chips ----- */
function renderChips(){
  const container = document.getElementById('chipContainer');
  container.innerHTML = '';
  State.categories.forEach(cat=>{
    const el = document.createElement('div');
    el.className = 'chip' + (State.activeCategory===cat ? ' active' : '');
    el.tabIndex = 0;
    el.textContent = cat;
    el.addEventListener('click', ()=>{
      State.activeCategory = cat; 
      renderChips(); 
      renderGrid();
    });
    container.appendChild(el);
  });
}

/* ----- render grid ----- */
function renderGrid(){
  const grid = document.getElementById('recipeGrid');
  grid.innerHTML = '';
  const q = State.query.trim().toLowerCase();
  let items = State.recipes.filter(r=>{
    if(State.activeCategory!=='Semua' && r.category!==State.activeCategory) return false;
    if(q && !r.title.toLowerCase().includes(q) && !r.category.toLowerCase().includes(q)) return false;
    return true;
  });
  if(items.length===0){
    grid.innerHTML = '<div style="grid-column:1/-1; color:#888; text-align:center; padding:24px;">Tidak ada resep ditemukan.</div>';
    return;
  }
  items.forEach(r=>{
    const card = document.createElement('div');
    card.className = 'card';
    card.innerHTML = `
      <div class="thumb" aria-hidden="true"></div>
      <h4>${r.title}</h4>
      <div class="meta">
        <small class="gray">${r.category}</small>
        <div style="display:flex;gap:8px;align-items:center;">
          <div class="fav-btn" data-id="${r.id}" title="Tambah favorit" aria-label="Tambah favorit">${State.favorites.has(r.id) ? '❤' : '♡'}</div>
        </div>
      </div>
    `;
    card.querySelector('.thumb').addEventListener('click', ()=>openDetail(r.id));
    card.querySelector('h4').addEventListener('click', ()=>openDetail(r.id));
    card.querySelector('.fav-btn').addEventListener('click', (e)=>{
      e.stopPropagation();
      toggleFav(r.id);
      renderGrid();
      renderFavList();
    });
    grid.appendChild(card);
  });
}

/* ----- open detail ----- */
function openDetail(id){
  const recipe = State.recipes.find(r=>r.id===id);
  if(!recipe) return;

  document.getElementById('detailTitle').textContent = recipe.title;
  document.getElementById('detailCategory').textContent = recipe.category;
  document.getElementById('detailThumb').style.background = '#ededed';

  const ing = document.getElementById('ingredients'); 
  ing.innerHTML = '';
  recipe.ingredients.forEach(i=>{
    const li = document.createElement('li'); 
    li.textContent = i; 
    ing.appendChild(li); 
  });

  const steps = document.getElementById('steps'); 
  steps.innerHTML = '';
  recipe.steps.forEach(s=>{
    const li = document.createElement('li'); 
    li.textContent = s; 
    steps.appendChild(li); 
  });

  document.getElementById('detailFav').textContent = State.favorites.has(id) ? '❤' : '♡';
  document.getElementById('favToggleDetail').textContent = State.favorites.has(id) ? 'Hapus Favorit' : 'Tambahkan ke Favorit';

  document.getElementById('favToggleDetail').onclick = ()=>{ 
    toggleFav(id); 
    openDetail(id); 
    renderGrid(); 
    renderFavList(); 
  };

  document.getElementById('shareBtn').onclick = async ()=>{
    const shareData = { title: recipe.title, text: `Coba resep "${recipe.title}" dari JadiMasak!`, url: location.href };
    if(navigator.share){ 
      try{ await navigator.share(shareData); } 
      catch(e){ alert('Share dibatalkan'); } 
    } else { 
      prompt('Copy & share link ini:', `${recipe.title} - JadiMasak (prototype)`); 
    }
  };

  document.getElementById('detailFav').onclick = ()=>{ toggleFav(id); openDetail(id); renderGrid(); renderFavList(); };
  document.getElementById('backFromDetail').onclick = ()=> showScreen('home');

  showScreen('detail');
}

/* ----- favorites management ----- */
function toggleFav(id){ 
  if(State.favorites.has(id)) State.favorites.delete(id); 
  else State.favorites.add(id); 
  saveFavs(); 
}

/* ----- render favorites list ----- */
function renderFavList(){
  const list = document.getElementById('favList');
  list.innerHTML = '';
  const favIds = Array.from(State.favorites);
  if(favIds.length===0){ 
    list.innerHTML = '<div style="padding:24px;color:#888;text-align:center">Belum ada favorit. Tandai resep favorit di halaman utama.</div>'; 
    return; 
  }

  favIds.forEach(id=>{
    const r = State.recipes.find(x=>x.id===id);
    if(!r) return;

    const item = document.createElement('div');
    item.className = 'favItem';
    item.innerHTML = `
      <div style="width:82px;height:62px;border-radius:8px;background:#eee;"></div>
      <div style="flex:1;">
        <div style="font-weight:700">${r.title}</div>
        <div style="font-size:12px;color:#777;margin-top:6px">${r.category}</div>
      </div>
      <div style="display:flex;flex-direction:column;gap:8px;">
        <button class="btn ghost" data-open="${r.id}">Buka</button>
        <button class="btn" data-remove="${r.id}">Hapus</button>
      </div>
    `;

    item.querySelector('[data-open]').addEventListener('click', ()=>openDetail(r.id));
    item.querySelector('[data-remove]').addEventListener('click', ()=>{
      toggleFav(r.id);
      renderFavList();
      renderGrid();
    });

    list.appendChild(item);
  });
}

/* -------------------------
   Init & event wiring
   ------------------------- */
function initApp(){
  initCategories();
  renderChips();
  renderGrid();
  renderFavList();

  setTimeout(()=>{ showScreen('home'); }, 900);

  const searchInput = document.getElementById('searchInput');
  searchInput.addEventListener('input', (e)=>{
    State.query = e.target.value;
    renderGrid();
  });

  document.getElementById('btn-fav-home').addEventListener('click', ()=>{ renderFavList(); showScreen('favorites'); });
  document.getElementById('closeFavorites').addEventListener('click', ()=> showScreen('home'));
}
initApp();

document.addEventListener('keydown', (e)=>{
  if(e.key==='Escape') showScreen('home');
});
