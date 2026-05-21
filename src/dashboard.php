<?php
require_once __DIR__ . '/db.php';

$errors = [];
$classVitt = [];
$affluenza = [];
$marcatori = [];

try {
    $stmt = $pdo->query('SELECT * FROM vistaclassificavittorie');
    $classVitt = $stmt->fetchAll();
} catch (PDOException $e) {
    $errors[] = 'Vista classifiche vittorie: ' . $e->getMessage();
}

try {
    $stmt = $pdo->query('SELECT * FROM vistaaffluenzamediastadi');
    $affluenza = $stmt->fetchAll();
} catch (PDOException $e) {
    $errors[] = 'Vista affluenza media stadi: ' . $e->getMessage();
}

$spName = 'getClassificaMarcatoriCompetizione';

try {
    $stmt = $pdo->query("CALL $spName('TOR26')");
    $marcatori = $stmt->fetchAll();
} catch (PDOException $e) {
    $errors[] = "Stored procedure $spName: " . $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="it">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard classifiche</title>
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
                <h2>Avvisi</h2>
                <ul>
                    <?php foreach ($errors as $error): ?>
                        <li><?php echo htmlspecialchars($error); ?></li>
                    <?php endforeach; ?>
                </ul>
            </section>
        <?php endif; ?>

        <section class="grid">
            <article class="card">
                <h2>Classifica Vittorie</h2>
                <?php if ($classVitt): ?>
                    <table>
                        <thead>
                            <tr>
                                <?php foreach (array_keys($classVitt[0]) as $col): ?>
                                    <th><?php echo htmlspecialchars($col); ?></th>
                                <?php endforeach; ?>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($classVitt as $row): ?>
                                <tr>
                                    <?php foreach ($row as $cell): ?>
                                        <td><?php echo htmlspecialchars((string)$cell); ?></td>
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
                <?php if ($affluenza): ?>
                    <table>
                        <thead>
                            <tr>
                                <?php foreach (array_keys($affluenza[0]) as $col): ?>
                                    <th><?php echo htmlspecialchars($col); ?></th>
                                <?php endforeach; ?>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($affluenza as $row): ?>
                                <tr>
                                    <?php foreach ($row as $cell): ?>
                                        <td><?php echo htmlspecialchars((string)$cell); ?></td>
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
                <h2>Classifica marcatori</h2>
                <?php if ($marcatori): ?>
                    <table>
                        <thead>
                            <tr>
                                <?php foreach (array_keys($marcatori[0]) as $col): ?>
                                    <th><?php echo htmlspecialchars($col); ?></th>
                                <?php endforeach; ?>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($marcatori as $row): ?>
                                <tr>
                                    <?php foreach ($row as $cell): ?>
                                        <td><?php echo htmlspecialchars((string)$cell); ?></td>
                                    <?php endforeach; ?>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php else: ?>
                    <p class="muted">Nessun dato disponibile dalla stored procedure.</p>
                <?php endif; ?>
            </article>
        </section>
    </main>
</body>

</html>