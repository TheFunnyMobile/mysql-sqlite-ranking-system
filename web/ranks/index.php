<!DOCTYPE html>
<html>

<head>

  <meta charset="UTF-8">

  <title>Ranking System</title>

  <link rel='stylesheet prefetch' href='http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css'>

    <link rel="stylesheet" href="css/style.css" media="screen" type="text/css" />

</head>

<body>

  <div class="container demo">
  <table class="datatable table table-striped table-bordered">
      <thead>
        <tr>
          <th>SteamID</th>
 
          <th>Player Name</th>
       
          <th>Kills</th>
 
          <th>Headshots</th>
          
          <th>Deaths</th>
 
          <th>Play Time</th>
        </tr>
      </thead>
 
      <tbody>
  <?php 

$link = mysqli_connect("localhost or ip to your MySQL server","Username","Password","rank_stats or the database you specified in the addon config") or die("Error " . mysqli_error($link)); 

$query = "SELECT  steamid, name, kills, headshots, deaths, plytime  FROM ranking_stats" or die("Error in the consult.." . mysqli_error($link)); 

$result = mysqli_query($link, $query); 

while($row = mysqli_fetch_array($result)) { 

  echo "<tr>";
  echo "<td>" . $row["steamid"] . "</td>"; 
  echo "<td>" . $row["name"] . "</td>"; 
  echo "<td>" . $row["kills"] . "</td>"; 
  echo "<td>" . $row["headshots"] . "</td>"; 
  echo "<td>" . $row["deaths"] . "</td>"; 
  echo "<td>" . $row["plytime"] . "</td>";  
  echo "</tr>";
  }
  echo "</table>";
 
?> 
    </tbody>
  </table>
</div>

  <script src='http://codepen.io/assets/libs/fullpage/jquery.js'></script>
  <script src='http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js'></script><script src='http://cdnjs.cloudflare.com/ajax/libs/datatables/1.9.4/jquery.dataTables.min.js'></script>

  <script src="js/index.js"></script>

</body>

</html>