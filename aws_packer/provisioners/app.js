// CORS (Cross-Origin Resource Sharing): Angular y Express generalmente corren en diferentes dominios o puertos durante el desarrollo. Para permitir la comunicación, incluye el middleware cors en tu backend, como en el ejemplo anterior.
// const express = require('express');
// const cors = require('cors');

// const app = express();
// const PORT = 3000;

// // Middleware para CORS
// app.use(cors());
// app.use(express.json());

// // Rutas de ejemplo
// app.get('/api/saludo', (req, res) => {
//     res.json({ mensaje: 'Hola desde el backend!' });
// });

// app.listen(PORT, () => {
//     console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
// });
////////////////////////////////////////////////////////////////////////77
// const express = require('express');
// const cors = require('cors');
// const mongoose = require('mongoose'); // cliente de MongoDB para Node.js (libreria) corre en el puerto 27017

// const app = express();
// const PORT = 3000;

// // URL de MongoDB
// const MONGO_URL = "mongodb://172.31.16.20:27017";

// // Middleware
// app.use(cors());
// app.use(express.json());

// // Variable para verificar el estado de la conexión
// let dbConnected = false;

// // Escuchar eventos de la conexión
// mongoose.connection.on('connected', () => {
//     console.log('Mongoose está conectado a MongoDB');
// });

// mongoose.connection.on('error', (err) => {
//     console.error('Error en la conexión de Mongoose:', err);
// });

// mongoose.connection.on('disconnected', () => {
//     console.log('Mongoose está desconectado de MongoDB');
// });

// // Conectar a MongoDB
// mongoose.connect(MONGO_URL, {
//     useNewUrlParser: true,
//     useUnifiedTopology: true,
// }).then((res) => {
//     console.log("Conexión exitosa a MongoDB:");
//     console.log(res); // Imprime la respuesta de la conexión
//     dbConnected = true;
// }).catch(err => {
//     console.error("Error al conectar a MongoDB:");
//     console.error(err); // Imprime el error
//     dbConnected = false;
// });

// // Ruta de ejemplo
// app.get('/api/saludo', (req, res) => {
//     if (dbConnected) {
//         res.json({ mensaje: 'Hola desde el backend conectado correctamente a MongoDB!' });
//     } else {
//         res.json({ mensaje: 'Hola desde el backend, pero no se pudo conectar a MongoDB.' });
//     }
// });

// // Iniciar el servidor
// app.listen(PORT, () => {
//     console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
// });
////////////////////////////////////////////////////////////////////////77
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose'); // cliente de MongoDB para Node.js (libreria) corre en el puerto 27017

const app = express();
const PORT = 3000;

// URL de MongoDB
const MONGO_URL = "mongodb://172.31.16.20:27017";

// Middleware
app.use(cors());
app.use(express.json());

// Variable para verificar el estado de la conexión
let dbConnected = false;

// Escuchar eventos de la conexión
mongoose.connection.on('connected', () => {
    console.log('Mongoose está conectado a MongoDB');
});

mongoose.connection.on('error', (err) => {
    console.error('Error en la conexión de Mongoose:', err);
});

mongoose.connection.on('disconnected', () => {
    console.log('Mongoose está desconectado de MongoDB');
});

// Conectar a MongoDB
mongoose.connect(MONGO_URL, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
}).then((res) => {
    console.log("Conexión exitosa a MongoDB:");
    console.log(res); // Imprime la respuesta de la conexión
    dbConnected = true;
}).catch(err => {
    console.error("Error al conectar a MongoDB:");
    console.error(err); // Imprime el error
    dbConnected = false;
});

// Ruta de ejemplo
app.get('/api/saludo', (req, res) => {
    if (dbConnected) {
        res.json({ mensaje: 'Hola desde el backend conectado correctamente a MongoDB!' });
    } else {
        res.json({ mensaje: 'Hola desde el backend, pero no se pudo conectar a MongoDB.' });
    }
});

// Iniciar el servidor
app.listen(PORT, () => {
    console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
});


