// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
export const firebaseConfig = {
  apiKey: "AIzaSyDRv-P6nUYyq--NxBV9hW9SMTqsSygm61c",
  authDomain: "chatapp-4b244.firebaseapp.com",
  projectId: "chatapp-4b244",
  storageBucket: "chatapp-4b244.appspot.com",
  messagingSenderId: "503990776702",
  appId: "1:503990776702:web:6faf9c5de482da5fec392f",
  measurementId: "G-J530VKK9GF",
};

// Initialize Firebase
export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);


