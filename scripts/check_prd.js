#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const docId = '1LBk3sP5H48edghAU8TcjxHFcX15pwA7S3fHFAuaE12E';
const url = `https://docs.google.com/document/d/${docId}/export?format=txt`;

const docsDir = path.join(__dirname, '..', 'docs');
const localPrdPath = path.join(docsDir, 'PRD_v1.0_sync.txt');
const tempPrdPath = path.join(docsDir, 'temp_prd.txt');

async function checkPrd() {
    console.log("=> Fetching latest PRD from Google Docs...");
    try {
        const response = await fetch(url);
        if (!response.ok) {
            console.error(`ERROR: Failed to fetch PRD. Status Code: ${response.status}`);
            process.exit(1);
        }
        
        let fetchedText = await response.text();
        // Normalize carriage returns for clean diffing
        fetchedText = fetchedText.replace(/\r/g, '');
        
        if (!fs.existsSync(docsDir)) {
            fs.mkdirSync(docsDir, { recursive: true });
        }
        
        fs.writeFileSync(tempPrdPath, fetchedText);
        
        if (!fs.existsSync(localPrdPath)) {
            console.log(`=> Initializing tracking for PRD. Saving baseline to ${localPrdPath}...`);
            fs.copyFileSync(tempPrdPath, localPrdPath);
            fs.unlinkSync(tempPrdPath);
            console.log("=> Baseline established.");
            return;
        }

        console.log("=> Comparing latest Google Doc against local tracking version...");
        try {
            // diff -u returns exit code 1 if differences are found
            const diffOutput = execSync(`diff -u "${localPrdPath}" "${tempPrdPath}"`, { encoding: 'utf-8' });
            console.log("=> No changes detected. PRD is up to date.");
        } catch (error) {
            if (error.status === 1) {
                console.log("========================================");
                console.log("🚨 CHANGES DETECTED IN THE GOOGLE DOC! 🚨");
                console.log("========================================");
                
                const lines = error.stdout.split('\n');
                lines.forEach(line => {
                    // Print added/removed lines but ignore the diff tool's file headers
                    if ((line.startsWith('+') || line.startsWith('-')) && 
                        !line.startsWith('+++') && !line.startsWith('---')) {
                        console.log(line);
                    }
                });
                
                // Auto-sync
                fs.copyFileSync(tempPrdPath, localPrdPath);
                console.log("========================================");
                console.log("=> Local PRD automatically synchronized with latest changes.");
            } else {
                console.error("Execution error:", error.message);
            }
        }
        
        if (fs.existsSync(tempPrdPath)) {
            fs.unlinkSync(tempPrdPath);
        }
        
    } catch (e) {
        console.error("Script failed:", e.message);
        process.exit(1);
    }
}

checkPrd();
