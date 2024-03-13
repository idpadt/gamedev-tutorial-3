## Latihan Mandiri: Eksplorasi Mekanika Pergerakan

### Double Jump
Untuk mekanik double jump tidak terlalu sulit. Saya hanya menambah variable air_jump untuk menandai berapa banyak jump yang bisa dilakukan di udara. Saat player jump di udara, air_jump berkurang 1. Saat player mendarat, single atau double jump, variable air_jump akan reset.

### Dashing
Mekanik dashing saat player double tap menurut saya yang paling sulit. Ada 2 mekanik yang perlu dipikirkan, yakni bagaimana cara mendeteksi double tap, dan mekanik dash itu sendiri. 

Pertama adalah double tap. Dari [post Reddit ini](https://www.reddit.com/r/godot/comments/9959v3/double_tap/), ada 2 saran bagaimana cara implementasi double tap, yakni menggunakan variabel yang bertambah setiap delta atau menggunakan node Timer. Melihat cara yang mudah, saya memilih menggunakan timer. Lalu dibantu oleh [video Youtube ini](https://www.youtube.com/watch?v=PK1Fum0t4iU), saya mempelajari cara menggunakan node Timer. Hasil yang saya buat adalah, saat player ke kiri atau kanan, akan ada variable bool dt_left atau dt_right menjadi true yang mendeteksi apakah siap untuk double tap (menggunakan 2 variabel untuk mengecek satu per satu apakah double tap kiri atau kanan), dan akan ada timer yang mulai. Saat timer durasinya habis (melewati double tap window), maka dt_left dan dt_right menjadi false kembali. Apabila player ke kiri atau ke kanan lagi saat bool dt_left atau dt_right masih true, maka akan terdeteksi sebagai double tap.

Yang kedua adalah mekanik dashnya itu sendiri. Dash dalam game biasanya ada 2 tipe, yang mirip running (dimana setelah double tap, kecepatan player akan naik namun akan tetap lebih cepat selama player menahan arah jalan) dan dash (dimana setelah double tap, kecepatan player akan naik namun hanya sementara, setelah itu akan menjadi normal speed lagi). Mekanik yang saya pilih adalah yang dash, dimana kenaikan speednya hanya sementara. Hasil yang saya buat adalah dengan timer node tambahan yang akan mencatat durasi dash. Saat sudah terdeteksi double tap, script akan mulai timer dan membuat bool is_dashing menjadi true. Lalu selama is_dashing true, player_speed akan menjadi menjadi dash_speed. Dan setelah is_dashing kembali menjadi false (yakni saat timer sudah menjadi 0), maka player_speed akan kembali menjadi normal_speed. Namun jika hanya merubah kecepatan, player akan terasa "snap" dari normal dan dashing speed. Untuk menambah transisi halus antara normal_speed dan dash_speed, saya membuat fungsi interpolasi sederhana yang terdampak oleh variabel speed_transition dan delta.

### Crouch
Untuk mekanik crouch sedikit sulit karena harus mengubah sprite dan collision shape dari player. [Video Youtube ini](https://www.youtube.com/watch?v=Hpbn-w7H2V4) mengajarkan cara mengambil child node, mengubah atributnya, dan mengatasi bug yang mungkin terjadi saat mengubah collision shape.

Dari mekanik ini ada satu bug yang belum saya temui solusinya, yakni saat lepas tombol down (berdiri lagi setelah crouch) namun space kurang untuk berdiri (ie collision shape yang berubah menjadi standing namun ada collision dari atas dan bawah).
