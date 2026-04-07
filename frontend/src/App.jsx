import { useEffect, useState } from 'react';

function App() {
  const [status, setStatus] = useState({ loading: true });

  useEffect(() => {
    fetch('/api/greeting')
      .then(async (response) => {
        if (!response.ok) {
          throw new Error('Failed to load greeting');
        }
        return response.json();
      })
      .then((data) => {
        setStatus({ loading: false, data });
      })
      .catch((error) => {
        setStatus({ loading: false, error: error.message });
      });
  }, []);

  if (status.loading) {
    return <p className="app__message">Loading...</p>;
  }

  if (status.error) {
    return <p className="app__message app__message--error">{status.error}</p>;
  }

  return (
    <main className="app">
      <section className="card">
        <h1>React + Spring Boot</h1>
        <p>{status.data?.message}</p>
        <p className="card__timestamp">
          Response generated at <strong>{new Date(status.data?.timestamp).toLocaleString()}</strong>
        </p>
        <p className="card__hint">
          Edit <code>frontend/src/App.jsx</code> to update the UI.
        </p>
      </section>
    </main>
  );
}

export default App;
