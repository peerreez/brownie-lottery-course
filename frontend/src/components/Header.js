// Header.js
import React from 'react';
import "./Header.css";

export const Header = () => {
    return (
        <div className="header-page">
            <header className="site-page-header">Smart Contract Lottery</header>
                <button type="button" className="connect-wallet">
                    Connect Wallet
                </button>
        </div>
    );
};
