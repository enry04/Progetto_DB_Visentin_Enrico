<?php
require_once __DIR__ . '/db.php';

$errors = [];
$success = [];

function postValue(string $key): string {
    return trim($_POST[$key] ?? '');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    try {
        if ($action === 'assign_arbitri') {
            $stmt = $pdo->prepare('CALL inserisci_sestetto_arbitrale(?, ?, ?, ?, ?, ?)');
            $stmt->execute([
                postValue('codicePartita'),
                postValue('codiceArbitro'),
                postValue('codicePrimoGuardalinee'),
                postValue('codiceSecondoGuardalinee'),
                postValue('codiceQuartoUomo'),
                postValue('codiceAssistenteVAR'),
            ]);
            $success[] = 'Sestetto arbitrale assegnato con successo.';
        } elseif ($action === 'insert_contratto') {
            $stmt = $pdo->prepare('INSERT INTO Contratto (numeroTesseramentoGiocatore, codiceClub, numeroMaglia, dataInizio, dataFine) VALUES (?, ?, ?, ?, ?)');
            $stmt->execute([
                postValue('numeroTesseramentoGiocatore'),
                postValue('codiceClub'),
                postValue('numeroMaglia'),
                postValue('dataInizio'),
                postValue('dataFine'),
            ]);
            $success[] = 'Contratto inserito con successo.';
        } elseif ($action === 'update_spettatori') {
            $stmt = $pdo->prepare('UPDATE Partita SET numeroSpettatori = ? WHERE codiceGara = ?');
            $stmt->execute([
                postValue('numeroSpettatori'),
                postValue('codiceGaraSpettatori'),
            ]);
            $success[] = 'Numero spettatori aggiornato per la partita.';
        } elseif ($action === 'insert_prestazione') {
            $stmt = $pdo->prepare('INSERT INTO Prestazione (numeroTesseramentoGiocatore, codiceGara, gol, assist, cartelliniGialli, cartelliniRossi) VALUES (?, ?, ?, ?, ?, ?)');
            $stmt->execute([
                postValue('numeroTesseramentoGiocatorePrestazione'),
                postValue('codiceGaraPrestazione'),
                postValue('gol'),
                postValue('assist'),
                postValue('cartelliniGialli'),
                postValue('cartelliniRossi'),
            ]);
            $success[] = 'Prestazione inserita con successo.';
        } elseif ($action === 'update_risultato') {
            $stmt = $pdo->prepare('UPDATE Partita SET stato = ?, risultato = ? WHERE codiceGara = ?');
            $stmt->execute([
                postValue('statoPartita'),
                postValue('risultatoPartita'),
                postValue('codiceGaraRisultato'),
            ]);
            $success[] = 'Stato e risultato partita aggiornati con successo.';
        }
    } catch (PDOException $e) {
        $errors[] = $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="it">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestione tornei calcistici</title>
    <link rel="stylesheet" href="css/style.css">
    <meta name="robots" content="noindex">
</head>

<body>
    <main class="container">
        <header class="site-header">
            <h1>Gestione tornei calcistici</h1>
            <p class="lead">Compila i form per eseguire le operazioni sul database.</p>
            <p><a class="btn" href="dashboard.php">Vai alla dashboard classifiche</a></p>
        </header>

        <?php if (!empty($errors)): ?>
            <section class="messages error-msg">
                <h2>Errore</h2>
                <ul>
                    <?php foreach ($errors as $error): ?>
                        <li><?php echo htmlspecialchars($error); ?></li>
                    <?php endforeach; ?>
                </ul>
            </section>
        <?php endif; ?>

        <?php if (!empty($success)): ?>
            <section class="messages success-msg">
                <h2>Operazione completata</h2>
                <ul>
                    <?php foreach ($success as $msg): ?>
                        <li><?php echo htmlspecialchars($msg); ?></li>
                    <?php endforeach; ?>
                </ul>
            </section>
        <?php endif; ?>

        <section class="grid">
            <article class="card">
                <h2>Assegna arbitri a partita</h2>
                <form method="post">
                    <input type="hidden" name="action" value="assign_arbitri">
                    <div class="field"><label>Codice partita<input type="text" name="codicePartita" required></label></div>
                    <div class="field"><label>Codice arbitro<input type="text" name="codiceArbitro" required></label></div>
                    <div class="field"><label>1° guardalinee<input type="text" name="codicePrimoGuardalinee" required></label></div>
                    <div class="field"><label>2° guardalinee<input type="text" name="codiceSecondoGuardalinee" required></label></div>
                    <div class="field"><label>Quarto uomo<input type="text" name="codiceQuartoUomo" required></label></div>
                    <div class="field"><label>Assistente VAR<input type="text" name="codiceAssistenteVAR" required></label></div>
                    <button class="btn" type="submit">Assegna sestetto</button>
                </form>
            </article>

            <article class="card">
                <h2>Inserisci contratto</h2>
                <form method="post">
                    <input type="hidden" name="action" value="insert_contratto">
                    <div class="field"><label>Numero tesseramento giocatore<input type="text" name="numeroTesseramentoGiocatore" required></label></div>
                    <div class="field"><label>Codice club<input type="text" name="codiceClub" required></label></div>
                    <div class="field"><label>Numero maglia<input type="number" name="numeroMaglia" min="1" required></label></div>
                    <div class="field"><label>Data inizio<input type="date" name="dataInizio" required></label></div>
                    <div class="field"><label>Data fine<input type="date" name="dataFine" required></label></div>
                    <button class="btn" type="submit">Inserisci contratto</button>
                </form>
            </article>

            <article class="card">
                <h2>Inserisci spettatori in partita</h2>
                <form method="post">
                    <input type="hidden" name="action" value="update_spettatori">
                    <div class="field"><label>Codice partita<input type="text" name="codiceGaraSpettatori" required></label></div>
                    <div class="field"><label>Numero spettatori<input type="number" name="numeroSpettatori" min="0" required></label></div>
                    <button class="btn" type="submit">Aggiorna spettatori</button>
                </form>
            </article>

            <article class="card">
                <h2>Inserisci prestazione</h2>
                <form method="post">
                    <input type="hidden" name="action" value="insert_prestazione">
                    <div class="field"><label>Numero tesseramento giocatore<input type="text" name="numeroTesseramentoGiocatorePrestazione" required></label></div>
                    <div class="field"><label>Codice partita<input type="text" name="codiceGaraPrestazione" required></label></div>
                    <div class="field"><label>Gol<input type="number" name="gol" min="0" required></label></div>
                    <div class="field"><label>Assist<input type="number" name="assist" min="0" required></label></div>
                    <div class="field"><label>Cartellini gialli<input type="number" name="cartelliniGialli" min="0" required></label></div>
                    <div class="field"><label>Cartellino rosso<select name="cartelliniRossi" required>
                        <option value="No">No</option>
                        <option value="Doppio giallo">Doppio giallo</option>
                        <option value="Rosso diretto">Rosso diretto</option>
                    </select></label></div>
                    <button class="btn" type="submit">Inserisci prestazione</button>
                </form>
            </article>

            <article class="card wide">
                <h2>Aggiorna stato e risultato partita</h2>
                <form method="post">
                    <input type="hidden" name="action" value="update_risultato">
                    <div class="field"><label>Codice partita<input type="text" name="codiceGaraRisultato" required></label></div>
                    <div class="field"><label>Stato partita<input type="text" name="statoPartita" required placeholder="es. conclusa"></label></div>
                    <div class="field"><label>Risultato<input type="text" name="risultatoPartita" required placeholder="es. 2-1"></label></div>
                    <button class="btn" type="submit">Aggiorna partita</button>
                </form>
            </article>
        </section>

        <footer class="site-footer">
            <p>Connessione: <?php echo isset($pdo) ? 'OK' : 'KO'; ?></p>
        </footer>
    </main>
</body>

</html>