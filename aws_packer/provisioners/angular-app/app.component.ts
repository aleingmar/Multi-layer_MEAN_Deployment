// import { Component, OnInit } from '@angular/core';
// import { HttpClient } from '@angular/common/http';

// @Component({
//   selector: 'app-root',
//   template: `
//     <h1>Hola Mundo desde Angular</h1>
//     <p>{{ message }}</p>
//   `,
//   styles: []
// })
// export class AppComponent implements OnInit {
//   message = 'Cargando mensaje...';

//   // URL dinámica, que será sustituida con Ansible
//   backendUrl = '__BACKEND_URL__';

//   constructor(private http: HttpClient) {}

//   ngOnInit(): void {
//     this.http.get<{ mensaje: string }>(`${this.backendUrl}/api/saludo`)
//       .subscribe({
//         next: (data) => this.message = data.mensaje,
//         error: (err) => this.message = 'Error conectando al backend'
//       });
//   }
// }
//////////////////////////////////////////////////
// import { Component, OnInit } from '@angular/core';

// @Component({
//   selector: 'app-root',
//   template: `
//     <h1>Hola Mundo desde Angular</h1>
//     <p>{{ message }}</p>
//   `,
//   styles: []
// })
// export class AppComponent implements OnInit {
//   message = 'Cargando mensaje...';

//   // URL dinámica, que será sustituida con Ansible
//   backendUrl = '__BACKEND_URL__';

//   // Identificador de instancia dinámico
//   num_instancia = '__NUM_INST__';

//   constructor() {}

//   ngOnInit(): void {
//     // Usamos la API fetch para realizar la solicitud HTTP
//     fetch(`${this.backendUrl}/api/saludo`)
//       .then(response => {
//         if (!response.ok) {
//           throw new Error('Error en la solicitud');
//         }
//         return response.json();
//       })
//       .then(data => {
//         this.message = data.mensaje; // Actualizamos el mensaje con la respuesta del backend
//       })
//       .catch(error => {
//         console.error('Error al obtener el mensaje:', error);
//         this.message = 'Error conectando al backend';
//       });
//   }
// }

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
  title = 'Hola Mundo desde Angular'; // Mensaje inicial en el <h1>
  message = 'Cargando mensaje...'; // Mensaje inicial en el <p>

  // Identificador de instancia dinámico
  num_instancia = '__NUM_INST__';

  // URL dinámica del backend
  backendUrl = '__BACKEND_URL__';

  constructor() {}

  ngOnInit(): void {
    // Actualiza el título del <h1> con el número de la instancia
    this.title = `Hola Mundo desde el Angular de la instancia ${this.num_instancia}`;

    // Solicita datos al backend
    fetch(`${this.backendUrl}/api/saludo`)
      .then(response => {
        if (!response.ok) {
          throw new Error('Error en la solicitud');
        }
        return response.json();
      })
      .then(data => {
        // Actualiza el mensaje en el <h1> con la respuesta del backend
        this.title = data.mensaje;
      })
      .catch(error => {
        console.error('Error al obtener el mensaje:', error);
        // Muestra un mensaje de error en el <h1>
        this.title = `Error conectando al backend desde la instancia ${this.num_instancia}`;
      });
  }
}