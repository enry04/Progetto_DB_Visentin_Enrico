<?php
require_once __DIR__ . '/db.php';

$errors = [];
$classVitt = [];
$affluenza = [];
$marcatori = [];
$competizione = 'SERIE_A_26'; 

try {
    $stmt = $pdo->query('SELECT * FROM VistaClassificaVittorie');
    $classVitt = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $errors[] = 'Vista classifiche vittorie: ' . $e->getMessage();
}

try {
    $stmt = $pdo->query('SELECT * FROM VistaAffluenzaMediaStadi');
    $affluenza = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    $errors[] = 'Vista affluenza media stadi: ' . $e->getMessage();
}

$spName = 'getClassificaMarcatoriCompetizione';

try {
    $stmt = $pdo->prepare("CALL $spName(?)");
    $stmt->execute([$competizione]);
    $marcatori = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $stmt->closeCursor(); 
} catch (PDOException $e) {
    $errors[] = "Stored procedure $spName: " . $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="it">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Statistiche Tornei</title>
    <link rel="stylesheet" href="css/style.css">
    <meta name="robots" content="noindex">
</head>

<body>
    <main class="container">
        <header class="site-header">
            <h1>Dashboard classifiche</h1>
            <p class="lead">Risultati delle viste e classifica marcatori</p>
            <p><a class="btn" href="index.php">Torna ai form</a></p>
        </header>

        <?php if (!empty($errors)): ?>
            <section class="messages error-msg">
                <h2>Avvisi di sistema</h2>
                <ul>
                    <?php foreach ($errors as $error): ?>
                        <li><?php echo htmlspecialchars($error, ENT_QUOTES, 'UTF-8'); ?></li>
                    <?php endforeach; ?>
                </ul>
            </section>
        <?php endif; ?>

        <section class="grid">
            <article class="card">
                <h2>Classifica Vittorie</h2>
                <?php if (!empty($classVitt)): ?>
                    <table>
                        <thead>
                            <tr>
                                <?php foreach (array_keys($classVitt[0]) as $col): ?>
                                    <th><?php echo htmlspecialchars(ucfirst($col), ENT_QUOTES, 'UTF-8'); ?></th>
                                <?php endforeach; ?>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($classVitt as $row): ?>
                                <tr>
                                    <?php foreach ($row as $cell): ?>
                                        <td><?php echo htmlspecialchars((string)$cell, ENT_QUOTES, 'UTF-8'); ?></td>
                                    <?php endforeach; ?>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php else: ?>
                    <p class="muted">Nessun dato disponibile.</p>
                <?php endif; ?>
            </article>

            <article class="card">
                <h2>Affluenza media stadi</h2>
                <?php if (!empty($affluenza)): ?>
                    <table>
                        <thead>
                            <tr>
                                <?php foreach (array_keys($affluenza[0]) as $col): ?>
                                    <th><?php echo htmlspecialchars(ucfirst($col), ENT_QUOTES, 'UTF-8'); ?></th>
                                <?php endforeach; ?>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($affluenza as $row): ?>
                                <tr>
                                    <?php foreach ($row as $cell): ?>
                                        <td><?php echo is_numeric($cell) && strpos($cell, '.') !== false ? htmlspecialchars(number_format($cell, 1), ENT_QUOTES, 'UTF-8') : htmlspecialchars((string)$cell, ENT_QUOTES, 'UTF-8'); ?></td>
                                    <?php endforeach; ?>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php else: ?>
                    <p class="muted">Nessun dato disponibile.</p>
                <?php endif; ?>
            </article>

            <article class="card wide">
                <h2>Classifica marcatori <?php echo htmlspecialchars($competizione, ENT_QUOTES, 'UTF-8'); ?></h2>
                <?php if (!empty($marcatori)): ?>
                    <table>
                        <thead>
                            <tr>
                                <?php foreach (array_keys($marcatori[0]) as $col): ?>
                                    <th><?php echo htmlspecialchars(ucfirst($col), ENT_QUOTES, 'UTF-8'); ?></th>
                                <?php endforeach; ?>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($marcatori as $row): ?>
                                <tr>
                                    <?php foreach ($row as $cell): ?>
                                        <td><?php echo htmlspecialchars((string)$cell, ENT_QUOTES, 'UTF-8'); ?></td>
                                    <?php endforeach; ?>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php else: ?>
                    <p class="muted">Nessun dato disponibile per questa competizione.</p>
                <?php endif; ?>
            </article>
        </section>
    </main>
</body>

</html>