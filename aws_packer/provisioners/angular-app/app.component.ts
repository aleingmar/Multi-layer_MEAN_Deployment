import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-root',
  template: `
    <h1>Hola Mundo desde Angular</h1>
    <p>{{ message }}</p>
  `,
  styles: []
})
export class AppComponent implements OnInit {
  message = 'Cargando mensaje...';

  // URL dinámica, que será sustituida con Ansible
  backendUrl = '__BACKEND_URL__';

  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    this.http.get<{ mensaje: string }>(`${this.backendUrl}/api/saludo`)
      .subscribe({
        next: (data) => this.message = data.mensaje,
        error: (err) => this.message = 'Error conectando al backend'
      });
  }
}
