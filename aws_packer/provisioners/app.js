
// ////////////////////////////////////////////////////////////////////////77
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

///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose'); // cliente de MongoDB para Node.js

const app = express(); // Asegúrate de que la variable `app` esté definida primero
const PORT = 3000;

// URL de MongoDB
const MONGO_URL = "mongodb://172.31.16.20:27017";

// Middleware
app.use(cors());
app.use(express.json());

// Variable para verificar el estado de la conexión
let dbConnected = false;

// Función para intentar conectarse a MongoDB con mensajes de depuración
async function connectToMongoDB() {
    console.log("Intentando conectar a MongoDB...");
    try {
        await new Promise(resolve => setTimeout(resolve, 5000)); // Esperar antes de conectar
        await mongoose.connect(MONGO_URL, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log("Conexión exitosa a MongoDB.");
        dbConnected = true;
    } catch (err) {
        console.error("Error al conectar a MongoDB:", err);
        dbConnected = false;

        // Reintentar conexión
        console.log("Esperando 5 segundos antes de reintentar...");
        await new Promise(resolve => setTimeout(resolve, 5000));
        return connectToMongoDB();
    }
}

// Escuchar eventos de la conexión
mongoose.connection.on('connected', () => {
    console.log('Mongoose está conectado a MongoDB.');
});

mongoose.connection.on('error', (err) => {
    console.error('Error en la conexión de Mongoose:', err);
});

mongoose.connection.on('disconnected', () => {
    console.log('Mongoose está desconectado de MongoDB.');
});

// Intentar conectarse a MongoDB
connectToMongoDB();

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
