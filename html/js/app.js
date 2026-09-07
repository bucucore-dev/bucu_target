// ============================================================================
// BUCU Core — Target Interaction NUI Controller
// Dynamic option rendering, audio synthesis, and key shortcuts
// ============================================================================

(function() {
    'use strict';

    const containerEl = document.getElementById('target-container');
    const eyeWrapperEl = document.getElementById('target-eye-wrapper');
    const menuEl = document.getElementById('target-menu');
    const optionsListEl = document.getElementById('target-options-list');

    let currentOptions = [];
    let audioCtx = null;

    // Web Audio API Sound Synthesizer
    function playChime(freq, type, duration) {
        try {
            if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = audioCtx.createOscillator();
            const gain = audioCtx.createGain();
            osc.type = type || 'sine';
            osc.frequency.setValueAtTime(freq || 580, audioCtx.currentTime);
            gain.gain.setValueAtTime(0.04, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + (duration || 0.12));
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.start();
            osc.stop(audioCtx.currentTime + (duration || 0.12));
        } catch (e) {}
    }

    function fetchPost(endpoint, data) {
        const resource = window.GetParentResourceName ? window.GetParentResourceName() : 'bucu_target';
        fetch(`https://${resource}/${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(data || {})
        }).catch(() => {});
    }

    // Icon helper
    function getIconGlyph(icon) {
        const icons = {
            'box': '📦',
            'wrench': '🔧',
            'gas-pump': '⛽',
            'hand': '✋',
            'user': '👤',
            'id-card': '🪪',
            'shield': '🛡️',
            'credit-card': '💳',
            'store': '🏪',
            'lock': '🔒',
            'unlock': '🔓'
        };
        return icons[icon] || '✦';
    }

    // Render Options List
    function renderOptions(options) {
        currentOptions = options || [];
        optionsListEl.innerHTML = '';

        if (!options || options.length === 0) {
            menuEl.classList.add('hidden');
            return;
        }

        options.forEach((opt, idx) => {
            const cardEl = document.createElement('div');
            cardEl.className = 'target-option-card';
            cardEl.innerHTML = `
                <div class="target-option-left">
                    <div class="target-option-icon">${getIconGlyph(opt.icon)}</div>
                    <div class="target-option-label">${opt.label}</div>
                </div>
                <div class="target-option-key">[${idx + 1}]</div>
            `;

            cardEl.addEventListener('mouseenter', () => {
                playChime(750, 'sine', 0.08);
            });

            cardEl.addEventListener('click', () => {
                playChime(950, 'triangle', 0.15);
                fetchPost('selectOption', { id: opt.id || (idx + 1) });
            });

            optionsListEl.appendChild(cardEl);
        });

        menuEl.classList.remove('hidden');
    }

    // NUI Message Listener
    window.addEventListener('message', (event) => {
        const item = event.data;
        if (!item || !item.action) return;

        if (item.action === 'openTarget') {
            containerEl.classList.remove('hidden');
            eyeWrapperEl.classList.remove('has-target');
            menuEl.classList.add('hidden');
            playChime(440, 'sine', 0.1);
        } else if (item.action === 'closeTarget') {
            containerEl.classList.add('hidden');
            eyeWrapperEl.classList.remove('has-target');
            menuEl.classList.add('hidden');
        } else if (item.action === 'updateTarget') {
            if (item.hasTarget) {
                if (!eyeWrapperEl.classList.contains('has-target')) {
                    playChime(820, 'sine', 0.12);
                }
                eyeWrapperEl.classList.add('has-target');
                renderOptions(item.options);
            } else {
                eyeWrapperEl.classList.remove('has-target');
                menuEl.classList.add('hidden');
            }
        }
    });

    // Close on Escape or right-click when in focus
    window.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            fetchPost('close', {});
        }
    });

    // Standalone Browser Preview Demo
    if (!window.invokeNative && window.location.protocol === 'file:') {
        containerEl.classList.remove('hidden');
        eyeWrapperEl.classList.add('has-target');
        renderOptions([
            { id: 1, icon: 'box', label: 'Buka / Tutup Bagasi' },
            { id: 2, icon: 'wrench', label: 'Periksa Kap Mesin' },
            { id: 3, icon: 'gas-pump', label: 'Cek Tangki Bahan Bakar' }
        ]);
    }
})();
