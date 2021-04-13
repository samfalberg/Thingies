var count = 0;

// Move the button around randomly
function move() {
    const width = window.innerWidth - 100;
    const height = window.innerHeight - 100;
    const button = document.getElementById('bttn');
    const buttonVal = document.getElementById('bttn-val')
    const title = document.getElementById('title');

    count++;
    if (count >= 10) {
        title.style.display = 'block';
        title.innerHTML = 'You did it';
        buttonVal.innerHTML = "Do it again";
        count = 0;
        return;
    }

    title.style.display = 'none';
    buttonVal.innerHTML = 'I don\'t know what to do';
    let top = Math.floor((Math.random() * width) + 1);
    let left = Math.floor((Math.random() * height) + 1);
    button.style.transform = `translate(${top}px, ${left}px)`;
}
