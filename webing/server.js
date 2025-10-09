const express = require('express');
const path = require('path');
const app = express();
const port = 3000;
//Importa la conexión
const db = require('./db');

//Permite recibir JSON en peticiones POST
app.use(express.json());

app.use(express.static(path.join(__dirname, 'public')));//carpeta hija

app.get('/', (req, res) => {
res.sendFile(path.join(__dirname, 'public', 'inicio-sesion.html'));
});

//Ejemplo de ruta que lee datos desde MySQL
app.get('/usuarios', (req, res) => {
  db.query('SELECT * FROM empleados', (err, results) => {
    if (err) {
      console.error('Error al consultar MySQL:', err);
      res.status(500).send('Error en la consulta');
      return;
    }
    res.json(results);
  });
});

//Inicia el servidor
app.listen(port, () => {
console.log(`Servidor iniciado en http://localhost:${port}`);
});