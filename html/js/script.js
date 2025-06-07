class MiningGame {
    constructor() {
        this.gridSize = { rows: 5, cols: 6 };
        this.totalCells = this.gridSize.rows * this.gridSize.cols;
        this.bombCount = 8;
        this.grid = [];
        this.revealedCells = [];
        this.gameActive = false;
        this.score = 0;
        this.baseReward = 25;
        this.multiplier = 1.0;
        this.revealedCount = 0;
        this.bombsHit = 0;
        this.maxBombsAllowed = 3;
        
        this.initializeUI();
    }

    initializeGrid() {
        this.grid = [];
        this.revealedCells = [];
        this.gameActive = true;
        this.score = 0;
        this.multiplier = 1.0;
        this.revealedCount = 0;
        this.bombsHit = 0;

        for (let i = 0; i < this.totalCells; i++) {
            this.grid.push('money');
            this.revealedCells.push(false);
        }

        this.placeBombs();
        this.updateUI();
    }

    placeBombs() {
        let bombsPlaced = 0;
        while (bombsPlaced < this.bombCount) {
            const randomIndex = Math.floor(Math.random() * this.totalCells);
            if (this.grid[randomIndex] !== 'bomb') {
                this.grid[randomIndex] = 'bomb';
                bombsPlaced++;
            }
        }
    }

    revealCell(index) {
        if (!this.gameActive || this.revealedCells[index]) {
            return false;
        }

        this.revealedCells[index] = true;
        this.revealedCount++;

        if (this.grid[index] === 'bomb') {
            this.bombsHit++;
            
            if (this.bombsHit >= this.maxBombsAllowed) {
                this.gameOver();
                return false;
            } else {
                this.updateUI();
                return true;
            }
        } else {
            this.score += this.baseReward;
            this.multiplier = 1 + (this.revealedCount * 0.1);
            this.updateUI();
            
            if (this.revealedCount >= this.totalCells - this.bombCount) {
                this.gameWin();
            }
            return true;
        }
    }

    gameOver() {
        this.gameActive = false;
        this.score = 0;
        this.revealAllBombs();
        document.getElementById('withdrawBtn').disabled = true;
        this.updateUI();
        
        $.post('https://alpha-cashier/gameFailed', JSON.stringify({
            message: 'انفجرت القنبلة! خسرت كل شيء'
        }));
        
        setTimeout(() => {
            $(".game-container").fadeOut();
        }, 500);
    }

    gameWin() {
        this.gameActive = false;
        const finalScore = Math.floor(this.score * this.multiplier);
        this.score = finalScore;
        this.updateUI();
        
        $.post('https://alpha-cashier/gameWon', JSON.stringify({
            score: finalScore
        }));
    }

    revealAllBombs() {
        for (let i = 0; i < this.totalCells; i++) {
            if (this.grid[i] === 'bomb') {
                this.revealedCells[i] = true;
            }
        }
        this.renderGrid();
    }

    getCurrentWinnings() {
        return Math.floor(this.score * this.multiplier);
    }

    withdraw() {
        if (!this.gameActive || this.score === 0) {
            return;
        }

        const winnings = this.getCurrentWinnings();
        this.score = 0;
        this.gameActive = false;
        document.getElementById('withdrawBtn').disabled = true;
        this.updateUI();
        
        $.post('https://alpha-cashier/withdrawCash', JSON.stringify({
            amount: winnings
        }));
        
        setTimeout(() => {
            $(".game-container").fadeOut();
        }, 500);
    }

    initializeUI() {
        this.renderGrid();
        this.updateUI();
    }

    renderGrid() {
        const gridElement = document.getElementById('gameGrid');
        gridElement.innerHTML = '';

        for (let i = 0; i < this.totalCells; i++) {
            const cell = document.createElement('div');
            cell.className = 'cell';
            cell.onclick = () => this.revealCell(i);

            if (this.revealedCells[i]) {
                cell.classList.add('revealed');
                if (this.grid[i] === 'bomb') {
                    cell.classList.add('bomb');
                    const icon = document.createElement('i');
                    icon.className = 'fa-solid fa-bomb';
                    icon.style.color = 'red';
                    cell.appendChild(icon);
                } else {
                    cell.classList.add('money');
                    const icon = document.createElement('i');
                    icon.className = 'fa-solid fa-sack-dollar';
                    icon.style.color = 'white';
                    cell.appendChild(icon);
                }
                cell.onclick = null;
            }

            gridElement.appendChild(cell);
        }
    }

    updateUI() {
        document.getElementById('scoreDisplay').textContent = '$' + this.getCurrentWinnings();
        document.getElementById('withdrawBtn').disabled = !this.gameActive || this.score === 0;
        
        this.renderGrid();
    }

    startNewGame() {
        this.initializeGrid();
    }
}

const game = new MiningGame();

function withdraw() {
    game.withdraw();
}

function startNewGame() {
    game.startNewGame();
}

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openGame') {
        $(".game-container").fadeIn();
        game.startNewGame();
    } else if (data.action === 'closeGame') {
        $(".game-container").fadeOut();
    }
});

document.onkeyup = function(data) {
    if (data.which == 27) {
        $.post('https://alpha-cashier/closeGame', JSON.stringify({}));
        $(".game-container").fadeOut();
    }
};

$(function() {
    $(".game-container").hide();
});