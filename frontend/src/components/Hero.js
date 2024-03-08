// Hero.js
import React from 'react';
import "./Hero.css";

// Cambiado de `Header` a `Hero` para que coincida con el nombre del archivo y su propósito
export const Hero = () => {
    return (
        <>
            <div className="hero-body">
                <div className="box-panel">
                    <h2>Admin Panel</h2>
                    <p>Lottery controls</p>
                    <div className="action-buttons">
                        <button className="primary-button">Start Lottery</button>
                        <button className="primary-button">End Lottery</button>
                    </div>
                    <p>The Lottery state is {}</p>
                </div>
                <div className="box-panel">
                    <h2>User Panel</h2>
                    <p>The entrance fee is {}</p>
                    <div className="action-buttons">
                        <button className="primary-button">Enter to Lottery</button>
                    </div>
                </div>
            </div>
        </>
    );
};
