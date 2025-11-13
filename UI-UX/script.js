/* script.js */

// Menjalankan script setelah semua konten HTML dimuat
document.addEventListener("DOMContentLoaded", () => {
  // --- Alur Halaman Login (index.html) ---
  const loginForm = document.getElementById("login-form");
  if (loginForm) {
    loginForm.addEventListener("submit", (e) => {
      e.preventDefault(); // Mencegah form submit sungguhan
      // Validasi sederhana (di dunia nyata, cek ke server)
      alert("Login Berhasil!");
      window.location.href = "beranda.html"; // Arahkan ke beranda
    });
  }

  const btnGotoDaftar = document.getElementById("btn-goto-daftar");
  if (btnGotoDaftar) {
    btnGotoDaftar.addEventListener("click", () => {
      window.location.href = "daftar.html"; // Arahkan ke halaman daftar
    });
  }

  // --- Alur Halaman Daftar (daftar.html) ---
  const registerForm = document.getElementById("register-form");
  if (registerForm) {
    registerForm.addEventListener("submit", (e) => {
      e.preventDefault();
      alert("Daftar Berhasil!");
      window.location.href = "index.html"; // Arahkan kembali ke login
    });
  }

  const btnGotoLogin = document.getElementById("btn-goto-login");
  if (btnGotoLogin) {
    btnGotoLogin.addEventListener("click", () => {
      window.location.href = "index.html"; // Arahkan ke halaman login
    });
  }

  // --- Alur Halaman Profil (profil.html) ---
  const btnLogout = document.getElementById("btn-logout");
  if (btnLogout) {
    btnLogout.addEventListener("click", () => {
      alert("Anda telah keluar.");
      window.location.href = "index.html"; // Arahkan ke halaman login
    });
  }

  // --- Alur Header (Beranda & Detail) ---
  const btnGotoSimpan = document.getElementById("btn-goto-simpan");
  if (btnGotoSimpan) {
    btnGotoSimpan.addEventListener("click", () => {
      window.location.href = "simpan.html";
    });
  }

  const btnGotoSimpanDetail = document.getElementById("btn-goto-simpan-detail");
  if (btnGotoSimpanDetail) {
    btnGotoSimpanDetail.addEventListener("click", () => {
        window.location.href = "simpan.html";
    });
  }

  // --- Tombol Kembali (Simpan & Detail) ---
  const btnBack = document.getElementById("btn-back");
  if(btnBack) {
      btnBack.addEventListener("click", () => {
          window.history.back(); // Kembali ke halaman sebelumnya
      });
  }
  
  const btnBackToBeranda = document.getElementById("btn-back-to-beranda");
  if(btnBackToBeranda) {
    btnBackToBeranda.addEventListener("click", () => {
          window.location.href = "beranda.html"; // Paksa kembali ke beranda
      });
  }

});