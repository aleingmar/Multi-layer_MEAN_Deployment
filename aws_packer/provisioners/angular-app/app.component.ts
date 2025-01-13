import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <h1>{{ title }}</h1>
    <p>{{ message }}</p>
  `,
  styles: []
})
export class AppComponent implements OnInit {
  title = ''; // Título dinámico
  message = 'Cargando mensaje...'; // Mensaje inicial

  // Identificador de instancia dinámico
  num_instancia = '__NUM_INST__';

  // URL dinámica del backend
  backendUrl = '__BACKEND_URL__';

  constructor() {}

  ngOnInit(): void {
    // Establecer el título inicial con el número de instancia
    this.title = `Hola Mundo desde el Angular de la instancia ${this.num_instancia}`;

    // Realizar la solicitud al backend para obtener el mensaje
    fetch(`${this.backendUrl}/api/saludo`)
      .then(response => {
        if (!response.ok) {
          throw new Error('Error en la solicitud');
        }
        return response.json();
      })
      .then(data => {
        // Actualizar el mensaje con la respuesta del backend
        this.message = data.mensaje;
      })
      .catch(error => {
        console.error('Error al obtener el mensaje:', error);
        // Mostrar un mensaje de error
        this.message = 'Error conectando al backend';
      });
  }
}
