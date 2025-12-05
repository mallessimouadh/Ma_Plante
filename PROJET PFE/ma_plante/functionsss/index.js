const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'tonemail@gmail.com', // Ton email Gmail
    pass: 'tonmotdepasse',     // Mot de passe d’application si 2FA
  },
});

exports.sendVerificationCode = functions.https.onCall(async (data, context) => {
  const { email, code } = data;

  const mailOptions = {
    from: 'tonemail@gmail.com',
    to: email,
    subject: 'Ton code de vérification - Ma Plante',
    text: `Voici ton code de vérification pour Ma Plante : ${code}`,
  };

  try {
    await transporter.sendMail(mailOptions);
    await admin.firestore().collection('verification_codes').doc(email).set({
      code: code,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: true };
  } catch (error) {
    console.error('Erreur lors de l’envoi :', error);
    throw new functions.https.HttpsError('internal', 'Erreur lors de l’envoi du code');
  }
});