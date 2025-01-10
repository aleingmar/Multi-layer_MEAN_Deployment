const express = require('express'); // Importar el módulo de Express
const app = express(); // Crear una instancia de la aplicación Express

// Definir la ruta raíz
app.get('/', (req, res) => {
  res.send('Hola Mundo'); // Responder con "Hola Mundo"
});

// Puerto en el que el servidor escuchará
const PORT = 3000;

// Iniciar el servidor
app.listen(PORT, () => {
  console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
});