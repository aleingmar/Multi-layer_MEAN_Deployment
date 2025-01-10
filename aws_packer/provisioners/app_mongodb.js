// const express = require('express');
// const mongoose = require('mongoose');
// const app = express();

// // Configuración de MongoDB
// const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/test';
// mongoose
//   .connect(mongoURI, { useNewUrlParser: true, useUnifiedTopology: true })
//   .then(() => console.log('MongoDB conectado'))
//   .catch(err => console.error('Error conectando a MongoDB:', err));

// // Ruta de prueba
// app.get('/', (req, res) => {
//   res.send('Hola Mundo! Express conectado a MongoDB');
// });

// CORS (Cross-Origin Resource Sharing): Angular y Express generalmente corren en diferentes dominios o puertos durante el desarrollo. Para permitir la comunicación, incluye el middleware cors en tu backend, como en el ejemplo anterior.
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 3000;

// Middleware para CORS
app.use(cors());
app.use(express.json());

// Rutas de ejemplo
app.get('/api/saludo', (req, res) => {
    res.json({ mensaje: 'Hola desde el backend!' });
});

app.listen(PORT, () => {
    console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
});
